'use strict';
/**
 * Bloom Phase 8.1 Seoul Test Data Cleanup Script
 *
 * Removes ONLY data written by phase8_1_seoul_seed.js:
 *   - users/test_seoul_001..100 (+ subcollections)
 *   - likes where fromUserId or toUserId starts with test_seoul_
 *   - matches where users[] contains any test_seoul_* id
 *   - RTDB status/test_seoul_*
 *   - test_seed_batches/phase8_1_seoul_001 metadata
 *
 * Does NOT touch any real user documents.
 *
 * Usage:
 *   node phase8_1_seoul_cleanup.js --dry-run
 *   node phase8_1_seoul_cleanup.js --confirm phase8_1_seoul_001
 */

// ── Dependency guard ──────────────────────────────────────────────────────────

let admin;
try {
  admin = require('firebase-admin');
} catch {
  console.error('\n[ERROR] firebase-admin is not installed.');
  console.error('  Run: npm install  (inside tools/seed/)');
  process.exit(1);
}

// ── Constants ─────────────────────────────────────────────────────────────────

const BATCH_NAME   = 'phase8_1_seoul_001';
const TEST_PREFIX  = 'test_seoul_';
const USER_COUNT   = 100;
const DELETE_CHUNK = 400; // keep well under Firestore's 500-op batch limit

// ── Argument parsing ──────────────────────────────────────────────────────────

const args       = process.argv.slice(2);
const isDryRun   = args.includes('--dry-run') || !args.includes('--confirm');
const confirmArg = args[args.indexOf('--confirm') + 1];
const confirmed  = confirmArg === BATCH_NAME;

const SERVICE_ACCOUNT = process.env.SERVICE_ACCOUNT_PATH || null;
const DATABASE_URL    = process.env.FIREBASE_DATABASE_URL || null;

// ── ID helpers ────────────────────────────────────────────────────────────────

function testUserId(n) {
  return `${TEST_PREFIX}${String(n).padStart(3, '0')}`;
}

const ALL_TEST_IDS = Array.from({ length: USER_COUNT }, (_, i) => testUserId(i + 1));

// ── Firebase init ─────────────────────────────────────────────────────────────

function initFirebase() {
  const appOptions = {};
  if (SERVICE_ACCOUNT) {
    try {
      const sa = require(require('path').resolve(SERVICE_ACCOUNT));
      appOptions.credential = admin.credential.cert(sa);
      appOptions.projectId  = sa.project_id;
    } catch (e) {
      console.error(`[ERROR] Could not load service account: ${e.message}`);
      process.exit(1);
    }
  } else {
    appOptions.credential = admin.credential.applicationDefault();
  }
  if (DATABASE_URL) appOptions.databaseURL = DATABASE_URL;
  admin.initializeApp(appOptions);
  return { db: admin.firestore(), rtdb: DATABASE_URL ? admin.database() : null };
}

// ── Batch delete helper ───────────────────────────────────────────────────────

function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) chunks.push(arr.slice(i, i + size));
  return chunks;
}

async function deleteDocs(db, refs, label) {
  if (refs.length === 0) { console.log(`  ✓ ${label}: nothing to delete`); return 0; }
  const chunks = chunkArray(refs, DELETE_CHUNK);
  let total = 0;
  for (let i = 0; i < chunks.length; i++) {
    if (!isDryRun) {
      const batch = db.batch();
      for (const ref of chunks[i]) batch.delete(ref);
      await batch.commit();
    }
    total += chunks[i].length;
    console.log(`  ${isDryRun ? '[DRY-RUN] Would delete' : '✓ Deleted'} ${label} chunk ${i + 1}/${chunks.length} (${chunks[i].length} docs)`);
  }
  return total;
}

// ── Subcollection deletion ────────────────────────────────────────────────────

async function deleteSubcollection(db, docRef, subcollectionName) {
  const snap = await docRef.collection(subcollectionName).get();
  if (snap.empty) return 0;
  const refs = snap.docs.map(d => d.ref);
  const chunks = chunkArray(refs, DELETE_CHUNK);
  let total = 0;
  for (const chunk of chunks) {
    if (!isDryRun) {
      const batch = db.batch();
      for (const ref of chunk) batch.delete(ref);
      await batch.commit();
    }
    total += chunk.length;
  }
  return total;
}

// ── Cleanup functions ─────────────────────────────────────────────────────────

async function countBeforeDelete(db) {
  console.log('\n  Counting documents to delete (this may take a moment)...');
  let userCount = 0, locationCount = 0, passCount = 0, blockCount = 0;
  let likeCount = 0, matchCount = 0;

  // Count existing test user docs
  for (const uid of ALL_TEST_IDS) {
    const snap = await db.collection('users').doc(uid).get();
    if (snap.exists) userCount++;
  }

  // Count likes involving test users (sent FROM test users)
  for (const uid of ALL_TEST_IDS) {
    const likeSnap = await db.collection('likes').where('fromUserId', '==', uid).get();
    likeCount += likeSnap.size;
  }
  // Count likes sent TO test users (rare, but clean them up)
  for (const uid of ALL_TEST_IDS) {
    const likeSnap = await db.collection('likes').where('toUserId', '==', uid).get();
    likeCount += likeSnap.size;
  }

  // Count matches involving test users
  for (const uid of ALL_TEST_IDS) {
    const matchSnap = await db.collection('matches').where('users', 'array-contains', uid).get();
    matchCount += matchSnap.size;
  }

  console.log(`    users to delete         : ${userCount}/${USER_COUNT}`);
  console.log(`    likes to delete         : ${likeCount}`);
  console.log(`    matches to delete       : ${matchCount}`);
  console.log(`    (subcollections counted separately during deletion)`);
  return { userCount, likeCount, matchCount };
}

async function cleanupUsers(db) {
  console.log(`\n[1/5] Deleting ${USER_COUNT} test user documents + subcollections...`);
  const userRefs = [];
  let subTotal = 0;

  for (const uid of ALL_TEST_IDS) {
    const userRef = db.collection('users').doc(uid);
    // Delete subcollections first
    subTotal += await deleteSubcollection(db, userRef, 'private');
    subTotal += await deleteSubcollection(db, userRef, 'passes');
    subTotal += await deleteSubcollection(db, userRef, 'blocks');
    userRefs.push(userRef);
  }

  if (subTotal > 0) {
    const action = isDryRun ? '[DRY-RUN] Would delete' : '✓ Deleted';
    console.log(`  ${action} ${subTotal} subcollection documents (private/location, passes, blocks)`);
  }

  await deleteDocs(db, userRefs, 'user docs');
}

async function cleanupLikes(db) {
  console.log('\n[2/5] Deleting likes involving test users...');
  const likeRefs = new Set();

  for (const uid of ALL_TEST_IDS) {
    const fromSnap = await db.collection('likes').where('fromUserId', '==', uid).get();
    fromSnap.docs.forEach(d => likeRefs.add(d.ref));

    const toSnap = await db.collection('likes').where('toUserId', '==', uid).get();
    toSnap.docs.forEach(d => likeRefs.add(d.ref));
  }

  await deleteDocs(db, [...likeRefs], 'likes');
}

async function cleanupMatches(db) {
  console.log('\n[3/5] Deleting matches involving test users...');
  const matchRefs = new Set();

  for (const uid of ALL_TEST_IDS) {
    const snap = await db.collection('matches').where('users', 'array-contains', uid).get();
    for (const doc of snap.docs) {
      // Delete messages subcollection first
      await deleteSubcollection(db, doc.ref, 'messages');
      matchRefs.add(doc.ref);
    }
  }

  await deleteDocs(db, [...matchRefs], 'matches');
}

async function cleanupRtdb(rtdb) {
  if (!rtdb) {
    console.log('\n[4/5] RTDB cleanup: skipped (FIREBASE_DATABASE_URL not set)');
    return;
  }
  console.log(`\n[4/5] Deleting ${USER_COUNT} RTDB presence entries...`);
  const updates = {};
  for (const uid of ALL_TEST_IDS) updates[`status/${uid}`] = null;
  if (!isDryRun) {
    await rtdb.ref('/').update(updates);
    console.log(`  ✓ ${USER_COUNT} status entries deleted`);
  } else {
    console.log(`  [DRY-RUN] Would delete ${USER_COUNT} RTDB status entries`);
  }
}

async function cleanupMetadata(db) {
  console.log('\n[5/5] Deleting seed metadata...');
  const ref = db.collection('test_seed_batches').doc(BATCH_NAME);
  if (!isDryRun) {
    await ref.delete();
    console.log(`  ✓ test_seed_batches/${BATCH_NAME} deleted`);
  } else {
    console.log(`  [DRY-RUN] Would delete test_seed_batches/${BATCH_NAME}`);
  }
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  if (!isDryRun && !confirmed) {
    console.error(`\n[ERROR] Missing or incorrect --confirm argument.`);
    console.error(`  To clean up, pass:  --confirm ${BATCH_NAME}`);
    console.error(`  To dry-run only:    --dry-run`);
    process.exit(1);
  }

  // Dry-run: show what would be deleted without initializing Firebase.
  // No credentials required for dry-run.
  if (isDryRun) {
    console.log('\n╔══════════════════════════════════════════════════════════════╗');
    console.log('║          Bloom Phase 8.1 Seoul Test Data Cleanup            ║');
    console.log('╚══════════════════════════════════════════════════════════════╝');
    console.log(`  Batch to remove : ${BATCH_NAME}`);
    console.log(`  Dry-run mode    : YES (no deletes)`);
    console.log('');
    console.log('  Would delete:');
    console.log(`    users/test_seoul_001 through users/test_seoul_100          (${USER_COUNT} docs)`);
    console.log(`    users/{id}/private/location                                (${USER_COUNT} docs)`);
    console.log(`    users/{id}/passes/*  and  users/{id}/blocks/*              (if present)`);
    console.log(`    likes where fromUserId or toUserId is any test_seoul_*     (queried at runtime)`);
    console.log(`    matches where users[] contains any test_seoul_*            (queried at runtime)`);
    console.log(`    matches/{id}/messages/*                                    (subcollection, if present)`);
    console.log(`    RTDB status/test_seoul_001..100                            (${DATABASE_URL ? USER_COUNT : 'skipped — no FIREBASE_DATABASE_URL'})`);
    console.log(`    test_seed_batches/${BATCH_NAME}                            (1 doc)`);
    console.log('');
    console.log('  Would NOT touch:');
    console.log('    Any document whose ID does not start with test_seoul_');
    console.log('    Any real user documents');
    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('  DRY-RUN COMPLETE — No data was deleted.');
    console.log(`  To delete: node phase8_1_seoul_cleanup.js --confirm ${BATCH_NAME}`);
    console.log('═══════════════════════════════════════════════════════════════\n');
    process.exit(0);
  }

  const { db, rtdb } = initFirebase();

  let projectId = '(unknown)';
  try { projectId = admin.app().options.projectId || projectId; } catch {}

  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║          Bloom Phase 8.1 Seoul Test Data Cleanup            ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log(`  Firebase project ID : ${projectId}`);
  console.log(`  Batch to remove     : ${BATCH_NAME}`);
  console.log(`  Dry-run mode        : NO (will delete)`);
  console.log('');
  console.log('  This cleanup will ONLY remove documents with IDs matching:');
  console.log(`    test_seoul_001 through test_seoul_100`);
  console.log('  It will NOT touch any other user documents.\n');

  const counts = await countBeforeDelete(db);

  if (counts.userCount === 0 && counts.likeCount === 0 && counts.matchCount === 0) {
    console.log('\n  ℹ  No seed data found. Nothing to clean up.');
    process.exit(0);
  }

  console.log('\n  ⚠  Deleting seed data in 3 seconds... Press Ctrl+C to abort.');
  await new Promise(r => setTimeout(r, 3000));

  try {
    await cleanupUsers(db);
    await cleanupLikes(db);
    await cleanupMatches(db);
    await cleanupRtdb(rtdb);
    await cleanupMetadata(db);

    console.log('\n╔══════════════════════════════════════════════════════════════╗');
    console.log('║                   Cleanup Complete ✓                        ║');
    console.log('╚══════════════════════════════════════════════════════════════╝');
    console.log(`  Batch ${BATCH_NAME} removed.\n`);
    process.exit(0);
  } catch (err) {
    console.error('\n[FATAL] Cleanup failed:', err);
    process.exit(1);
  }
}

main();
