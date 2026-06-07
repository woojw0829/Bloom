'use strict';
/**
 * Bloom Phase 8.1 Seoul Test Data Seed Script
 *
 * Writes 100 synthetic Seoul-area test users to Firestore + RTDB.
 * Optionally writes incoming likes, existing matches, passes, and
 * chat preview data for a specified CURRENT_USER_ID.
 *
 * SAFETY: All generated users have deterministic IDs (test_seoul_001..100)
 * and are clearly marked as test data. Script will NOT write to any real
 * user document. Run without --confirm to perform a dry-run only.
 *
 * Usage:
 *   node phase8_1_seoul_seed.js --dry-run
 *   node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001
 *   CURRENT_USER_ID=<uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes
 *   CURRENT_USER_ID=<uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches
 *   CURRENT_USER_ID=<uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-existing-matches --seed-chat-previews
 *   CURRENT_USER_ID=<uid> node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001 --seed-incoming-likes --seed-passes
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

const BATCH_NAME      = 'phase8_1_seoul_001';
const TEST_PREFIX     = 'test_seoul_';
const USER_COUNT      = 100;
const SEED_PURPOSE    = 'phase6_discovery_phase7_matching_phase8_1_chat';
const FIRESTORE_CHUNK = 450; // max operations per commit (Firestore limit: 500)

// Slot assignments (all users 1-100 always seeded; slots define relational data)
const LIKE_SLOTS           = { start: 1,  end: 30 }; // incoming likes → CURRENT_USER_ID
const LIKE_NORMAL_END      = 24;                     // 001..024 = 'like', 025..030 = 'super_like'
const MATCH_SLOTS          = { start: 31, end: 35 }; // existing matches with CURRENT_USER_ID
const PASS_SLOTS           = { start: 36, end: 40 }; // CURRENT_USER_ID passes these users

// ── Argument parsing ──────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const isDryRun         = args.includes('--dry-run') || !args.includes('--confirm');
const confirmArg       = args[args.indexOf('--confirm') + 1];
const confirmed        = confirmArg === BATCH_NAME;
const seedLikes        = args.includes('--seed-incoming-likes');
const seedMatches      = args.includes('--seed-existing-matches');
const seedPasses       = args.includes('--seed-passes');
const seedChatPreviews = args.includes('--seed-chat-previews');

const CURRENT_USER_ID  = process.env.CURRENT_USER_ID || null;
const SERVICE_ACCOUNT  = process.env.SERVICE_ACCOUNT_PATH || null;
const DATABASE_URL     = process.env.FIREBASE_DATABASE_URL || null;

// ── Seoul neighborhoods ───────────────────────────────────────────────────────
// 20 neighborhoods × 5 users = 100 users
// Coordinates are realistic Seoul/metro locations; individual users get small jitter.

const NEIGHBORHOODS = [
  { name: 'Gangnam',             city: 'Seoul (Gangnam)',          lat: 37.4979, lng: 127.0276 },
  { name: 'Yeoksam',             city: 'Seoul (Yeoksam)',          lat: 37.5004, lng: 127.0360 },
  { name: 'Jamsil',              city: 'Seoul (Jamsil)',           lat: 37.5133, lng: 127.1000 },
  { name: 'Hongdae',             city: 'Seoul (Hongdae)',          lat: 37.5563, lng: 126.9236 },
  { name: 'Sinchon',             city: 'Seoul (Sinchon)',          lat: 37.5552, lng: 126.9368 },
  { name: 'Mapo',                city: 'Seoul (Mapo)',             lat: 37.5583, lng: 126.9095 },
  { name: 'Yeouido',             city: 'Seoul (Yeouido)',          lat: 37.5219, lng: 126.9245 },
  { name: 'Jongno',              city: 'Seoul (Jongno)',           lat: 37.5720, lng: 126.9793 },
  { name: 'Euljiro',             city: 'Seoul (Euljiro)',          lat: 37.5662, lng: 126.9908 },
  { name: 'Itaewon',             city: 'Seoul (Itaewon)',          lat: 37.5350, lng: 126.9945 },
  { name: 'Yongsan',             city: 'Seoul (Yongsan)',          lat: 37.5327, lng: 126.9651 },
  { name: 'Seongsu',             city: 'Seoul (Seongsu)',          lat: 37.5444, lng: 127.0560 },
  { name: 'Konkuk',              city: 'Seoul (Konkuk-dong)',      lat: 37.5402, lng: 127.0717 },
  { name: 'Wangsimni',           city: 'Seoul (Wangsimni)',        lat: 37.5606, lng: 127.0374 },
  { name: 'Nowon',               city: 'Seoul (Nowon)',            lat: 37.6543, lng: 127.0570 },
  { name: 'Gwanak',              city: 'Seoul (Gwanak)',           lat: 37.4764, lng: 126.9522 },
  { name: 'Sadang',              city: 'Seoul (Sadang)',           lat: 37.4786, lng: 126.9813 },
  { name: 'Mokdong',             city: 'Seoul (Mokdong)',          lat: 37.5270, lng: 126.8747 },
  { name: 'Gimpo',               city: 'Seoul Metro (Gimpo)',      lat: 37.5579, lng: 126.7993 },
  { name: 'Bundang',             city: 'Seoul Metro (Bundang)',    lat: 37.3797, lng: 127.1187 },
];

// ── App enum values (exact strings used by the Flutter app) ──────────────────

const IDENTITIES = [
  'Gay', 'Lesbian', 'Bisexual', 'Transgender', 'Non-binary',
  'Queer', 'Questioning', 'Pansexual', 'Asexual', 'Intersex', 'Prefer not to say',
];

const RELATIONSHIP_GOALS = [
  'Serious Relationship', 'Casual Dating', 'Open to Anything', 'Friendship', 'Not Sure Yet',
];

const INTERESTS = [
  'Travel', 'Music', 'Coffee', 'Fitness', 'Cooking', 'Reading', 'Gaming', 'Photography',
  'Art', 'Movies', 'Hiking', 'Dancing', 'Yoga', 'Pets', 'Fashion', 'Technology',
  'Sports', 'Nature', 'Volunteering', 'Food', 'Wine', 'Theatre', 'Writing', 'Meditation',
];

const BIO_SUFFIXES = [
  'Coffee enthusiast and weekend hiker.',
  'Books, music, and long walks on the Han River.',
  'Tech worker who loves cooking at home.',
  'Art lover exploring Seoul\'s galleries and cafés.',
  'Fitness enthusiast and travel photographer.',
  'Board games and indie music on weekends.',
  'Yoga practitioner and nature lover.',
  'Film fan who reviews movies on the side.',
  'Animal person who volunteers at local shelters.',
  'Runner training for a marathon.',
  'Homebrewing coffee and reading science fiction.',
  'Theatre enthusiast and amateur writer.',
  'Dancing and meditation keep me grounded.',
  'Foodie documenting Seoul\'s best spots.',
  'Always up for trying new experiences.',
];

const SAFE_CHAT_MESSAGES = [
  'Bloom test message. Nice to connect!',
  'Test chat preview for QA. Hello!',
  'Synthetic conversation preview for testing.',
  'Phase 8.1 test. Looking forward to chatting.',
  'QA test message. This is seed data.',
];

// ── Deterministic pseudo-random (seeded) ─────────────────────────────────────
// Used to produce consistent, reproducible test data without Math.random().

function makeRng(seed) {
  let s = (seed + 1) * 1664525 + 1013904223;
  return function () {
    s = ((s * 1664525 + 1013904223) & 0xffffffff) >>> 0;
    return s / 0xffffffff;
  };
}

// ── GeoHash encoder (exact port of GeoHashUtils.dart, precision=5) ───────────

const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

function encodeGeoHash(lat, lng, precision = 5) {
  let minLat = -90, maxLat = 90;
  let minLng = -180, maxLng = 180;
  let result = '';
  let bits = 0, bitsTotal = 0, hashValue = 0;

  while (result.length < precision) {
    if (bitsTotal % 2 === 0) {
      const mid = (minLng + maxLng) / 2;
      if (lng >= mid) { hashValue = (hashValue << 1) | 1; minLng = mid; }
      else             { hashValue = hashValue << 1;       maxLng = mid; }
    } else {
      const mid = (minLat + maxLat) / 2;
      if (lat >= mid) { hashValue = (hashValue << 1) | 1; minLat = mid; }
      else            { hashValue = hashValue << 1;       maxLat = mid; }
    }
    bitsTotal++;
    bits++;
    if (bits === 5) {
      result += BASE32[hashValue];
      bits = 0;
      hashValue = 0;
    }
  }
  return result;
}

// ── User ID helpers ───────────────────────────────────────────────────────────

function testUserId(n) {
  return `${TEST_PREFIX}${String(n).padStart(3, '0')}`;
}

function isTestId(id) {
  return id.startsWith(TEST_PREFIX);
}

// ── Per-user data generation ──────────────────────────────────────────────────

function generateUserCoords(n) {
  const neighborhoodIdx = Math.floor((n - 1) / 5); // 0..19
  const slotInNeighborhood = (n - 1) % 5;           // 0..4
  const hood = NEIGHBORHOODS[neighborhoodIdx];
  const rng = makeRng(n * 17 + slotInNeighborhood * 31);

  // Jitter: ±0.004° ≈ ±400 m
  const latJitter = (rng() - 0.5) * 0.008;
  const lngJitter = (rng() - 0.5) * 0.008;
  const lat = +(hood.lat + latJitter).toFixed(6);
  const lng = +(hood.lng + lngJitter).toFixed(6);
  return { lat, lng, city: hood.city };
}

function generateUserDoc(n) {
  const userId = testUserId(n);
  const { lat, lng, city } = generateUserCoords(n);
  const geoHash = encodeGeoHash(lat, lng);
  const rng = makeRng(n * 97);

  // Age: 20-45 distributed across users
  const age = 20 + ((n - 1) % 26);

  // birthDate: vary month/day to avoid identical timestamps
  const now = new Date();
  const birthYear = now.getFullYear() - age;
  const birthMonth = ((n * 3) % 12);
  const birthDay = ((n * 7) % 28) + 1;
  const birthDate = new Date(birthYear, birthMonth, birthDay);

  // Identity: distributed across all 11 values
  const identityMap = [
    ...Array(20).fill('Gay'),
    ...Array(15).fill('Lesbian'),
    ...Array(15).fill('Bisexual'),
    ...Array(10).fill('Transgender'),
    ...Array(10).fill('Non-binary'),
    ...Array(10).fill('Queer'),
    ...Array(5).fill('Questioning'),
    ...Array(5).fill('Pansexual'),
    ...Array(4).fill('Asexual'),
    ...Array(3).fill('Intersex'),
    ...Array(3).fill('Prefer not to say'),
  ];
  const identity = identityMap[n - 1];

  // Relationship goal: even distribution (20 each)
  const relationshipGoal = RELATIONSHIP_GOALS[(n - 1) % RELATIONSHIP_GOALS.length];

  // Interests: 3-7 per user, cycling through the list
  const interestCount = 3 + ((n - 1) % 5);
  const startIdx = ((n - 1) * 3) % INTERESTS.length;
  const userInterests = [];
  for (let i = 0; i < interestCount; i++) {
    userInterests.push(INTERESTS[(startIdx + i) % INTERESTS.length]);
  }

  // Verification level: ~10% government_id, ~30% photo, ~60% none
  let verificationLevel;
  const vMod = (n - 1) % 10;
  if (vMod === 0) verificationLevel = 'government_id';
  else if (vMod <= 3) verificationLevel = 'photo';
  else verificationLevel = 'none';

  // Premium: ~20% true
  const premium = (n - 1) % 5 === 0;

  // Height (optional): present for ~60% of users
  const height = n % 5 !== 0 ? 155 + ((n * 7) % 31) : undefined;

  // Profile images: 1 for non-premium, 2-3 for premium users
  const paddedN = String(n).padStart(3, '0');
  const profileImages = [
    `https://placehold.co/800x1000/00C896/FFFFFF/png?text=Bloom+Test+${paddedN}`,
  ];
  if (premium) {
    profileImages.push(
      `https://placehold.co/800x1000/FF6B6B/FFFFFF/png?text=Bloom+Test+${paddedN}+2`,
      `https://placehold.co/800x1000/6B9DFF/FFFFFF/png?text=Bloom+Test+${paddedN}+3`,
    );
  } else if (n % 3 === 0) {
    profileImages.push(
      `https://placehold.co/800x1000/FFB347/FFFFFF/png?text=Bloom+Test+${paddedN}+2`,
    );
  }

  // Bio
  const bioSuffix = BIO_SUFFIXES[(n - 1) % BIO_SUFFIXES.length];
  const bio = `Bloom Seoul test profile ${paddedN}. ${bioSuffix}`;

  // Stagger updatedAt so discovery feed ordering is realistic (1 min apart)
  const now2 = new Date();
  const updatedAt = new Date(now2.getTime() - (n - 1) * 60 * 1000);
  const createdAt = new Date(updatedAt.getTime() - 30 * 24 * 60 * 60 * 1000);

  const doc = {
    id: userId,
    email: `${userId}@bloomtest.invalid`,
    nickname: `SeoulTest${paddedN}`,
    birthDate: admin.firestore.Timestamp.fromDate(birthDate),
    age,
    identity,
    relationshipGoal,
    bio,
    interests: userInterests,
    city,
    geoHash,
    profileImages,
    profileVisibility: 'public',
    accountStatus: 'active',
    verificationLevel,
    premium,
    premiumBadgeVisible: premium,
    fcmToken: '',
    isOnline: true,
    lastSeen: admin.firestore.Timestamp.fromDate(new Date()),
    onlineStatusVisible: true,
    lastSeenVisible: true,
    notificationSettings: { match: true, message: true, like: true, verification: true },
    compatibilityPreferences: {
      minAge: 18,
      maxAge: 45,
      maxDistanceKm: 50,
      identities: [],
      relationshipGoals: [],
    },
    createdAt: admin.firestore.Timestamp.fromDate(createdAt),
    updatedAt: admin.firestore.Timestamp.fromDate(updatedAt),
    // Test markers — safely ignored by UserModel.fromJson (freezed ignores unknown fields)
    isTestUser: true,
    testSeedBatch: BATCH_NAME,
    testSeedPurpose: SEED_PURPOSE,
  };

  if (height !== undefined) doc.height = height;

  return { userId, doc, lat, lng };
}

function generatePrivateLocation(userId, lat, lng) {
  return {
    location: new admin.firestore.GeoPoint(lat, lng),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function generateLikeDoc(fromUserId, toUserId, type) {
  const id = `${fromUserId}_${toUserId}`;
  return {
    id,
    fromUserId,
    toUserId,
    type,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function generateMatchDoc(matchId, userId1, userId2, compatibilityScore) {
  return {
    id: matchId,
    users: [userId1, userId2],
    compatibilityScore,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessageAt: null,
    lastMessagePreview: '',
    active: true,
  };
}

function generateMatchId(userId1, userId2) {
  // Deterministic: sort IDs so the same pair always produces the same match ID
  const [a, b] = [userId1, userId2].sort();
  return `match_${a}_${b}`;
}

// ── Plan summary ──────────────────────────────────────────────────────────────

function printPlan(db, rtdb) {
  const likeCount = seedLikes && CURRENT_USER_ID
    ? (LIKE_SLOTS.end - LIKE_SLOTS.start + 1)
    : 0;
  const matchCount = seedMatches && CURRENT_USER_ID
    ? (MATCH_SLOTS.end - MATCH_SLOTS.start + 1)
    : 0;
  const passCount = seedPasses && CURRENT_USER_ID
    ? (PASS_SLOTS.end - PASS_SLOTS.start + 1)
    : 0;
  const chatPreviewCount = seedChatPreviews && CURRENT_USER_ID ? matchCount : 0;

  let projectId = isDryRun ? '(dry-run — not connected)' : '(unknown — check service account)';
  if (db !== null) {
    try { projectId = admin.app().options.projectId || projectId; } catch {}
  }

  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║          Bloom Phase 8.1 Seoul Test Data Seed Plan           ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log(`  Firebase project ID  : ${projectId}`);
  console.log(`  Batch name           : ${BATCH_NAME}`);
  console.log(`  Dry-run mode         : ${isDryRun ? 'YES (no writes)' : 'NO (will write)'}`);
  console.log(`  CURRENT_USER_ID      : ${CURRENT_USER_ID || '(not set)'}`);
  console.log('');
  console.log('  Firestore writes:');
  console.log(`    users/{id}                        : ${USER_COUNT}`);
  console.log(`    users/{id}/private/location       : ${USER_COUNT}`);
  console.log(`    test_seed_batches/${BATCH_NAME}   : 1`);
  if (likeCount > 0)
    console.log(`    likes/{fromId}_{CURRENT_USER_ID}  : ${likeCount}  (${LIKE_NORMAL_END} like + ${likeCount - LIKE_NORMAL_END} super_like)`);
  if (matchCount > 0)
    console.log(`    matches/{matchId}                 : ${matchCount}  (existing matches)`);
  if (passCount > 0)
    console.log(`    users/CURRENT_USER_ID/passes/{id} : ${passCount}`);
  if (chatPreviewCount > 0)
    console.log(`    matches/{matchId} (preview update): ${chatPreviewCount}  (--seed-chat-previews)`);
  console.log('');
  const rtdbCount = DATABASE_URL ? USER_COUNT : 0;
  const rtdbNote  = DATABASE_URL ? '' : '(skipped — FIREBASE_DATABASE_URL not set)';
  console.log('  Realtime Database writes:');
  console.log(`    status/{testUserId}               : ${rtdbCount}  ${rtdbNote}`);
  console.log('');
  if (!seedLikes && CURRENT_USER_ID)
    console.log('  ℹ  Pass --seed-incoming-likes to create incoming likes for CURRENT_USER_ID');
  if (!seedMatches && CURRENT_USER_ID)
    console.log('  ℹ  Pass --seed-existing-matches to create pre-built matches');
  if (!seedPasses && CURRENT_USER_ID)
    console.log('  ℹ  Pass --seed-passes to create pass records for CURRENT_USER_ID');
  if (!seedChatPreviews && CURRENT_USER_ID && matchCount > 0)
    console.log('  ℹ  Pass --seed-chat-previews to populate lastMessagePreview on matches');
  if (!CURRENT_USER_ID)
    console.log('  ℹ  Set CURRENT_USER_ID=<uid> to enable like/match/pass seeding');
  console.log('');
}

// ── Firestore batch helpers ───────────────────────────────────────────────────

function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}

async function commitBatches(db, operations, label) {
  if (operations.length === 0) return;
  const chunks = chunkArray(operations, FIRESTORE_CHUNK);
  for (let i = 0; i < chunks.length; i++) {
    const batch = db.batch();
    for (const op of chunks[i]) {
      if (op.type === 'set')    batch.set(op.ref, op.data, op.options || {});
      if (op.type === 'update') batch.update(op.ref, op.data);
    }
    await batch.commit();
    console.log(`  ✓ ${label} chunk ${i + 1}/${chunks.length} committed (${chunks[i].length} ops)`);
  }
}

// ── Seed functions ────────────────────────────────────────────────────────────

async function seedUsers(db) {
  console.log(`\n[1/6] Seeding ${USER_COUNT} user documents...`);
  const userSummary = [];

  if (isDryRun) {
    // Dry-run: generate sample data only, no Firestore refs needed.
    for (let n = 1; n <= USER_COUNT; n++) {
      const { userId, doc, lat, lng } = generateUserDoc(n);
      if (n <= 3 || n === USER_COUNT) {
        userSummary.push({ userId, lat: lat.toFixed(5), lng: lng.toFixed(5), geoHash: doc.geoHash });
      }
    }
    console.log(`  [DRY-RUN] Would write ${USER_COUNT} user docs + ${USER_COUNT} private/location docs`);
    console.log('  Sample users:');
    for (const s of userSummary) {
      console.log(`    ${s.userId}  lat=${s.lat} lng=${s.lng}  geoHash=${s.geoHash}`);
    }
    return;
  }

  const ops = [];
  const locationOps = [];
  for (let n = 1; n <= USER_COUNT; n++) {
    const { userId, doc, lat, lng } = generateUserDoc(n);
    ops.push({ type: 'set', ref: db.collection('users').doc(userId), data: doc });
    locationOps.push({
      type: 'set',
      ref: db.collection('users').doc(userId).collection('private').doc('location'),
      data: generatePrivateLocation(userId, lat, lng),
    });
  }
  await commitBatches(db, ops, 'users');
  await commitBatches(db, locationOps, 'private/location');
}

async function seedRtdb(rtdb) {
  if (!rtdb) {
    console.log('\n[2/6] RTDB: skipped (FIREBASE_DATABASE_URL not set)');
    return;
  }
  console.log(`\n[2/6] Seeding ${USER_COUNT} RTDB presence entries...`);
  const now = Date.now();
  const updates = {};
  for (let n = 1; n <= USER_COUNT; n++) {
    const userId = testUserId(n);
    updates[`status/${userId}`] = { isOnline: true, lastSeen: now };
  }
  if (!isDryRun) {
    await rtdb.ref('/').update(updates);
    console.log(`  ✓ ${USER_COUNT} status entries written`);
  } else {
    console.log(`  [DRY-RUN] Would write ${USER_COUNT} RTDB status entries`);
    console.log(`  Example: status/test_seoul_001 = { isOnline: true, lastSeen: ${now} }`);
  }
}

async function seedMetadata(db) {
  console.log('\n[3/6] Writing seed metadata...');
  const meta = {
    batchName: BATCH_NAME,
    purpose: SEED_PURPOSE,
    userCount: USER_COUNT,
    userIdRange: `${testUserId(1)} – ${testUserId(USER_COUNT)}`,
    currentUserId: CURRENT_USER_ID || null,
    seededLikes: seedLikes,
    seededMatches: seedMatches,
    seededPasses: seedPasses,
    seededChatPreviews: seedChatPreviews,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (!isDryRun) {
    await db.collection('test_seed_batches').doc(BATCH_NAME).set(meta);
    console.log(`  ✓ test_seed_batches/${BATCH_NAME} written`);
  } else {
    console.log(`  [DRY-RUN] Would write test_seed_batches/${BATCH_NAME}`);
  }
}

async function seedIncomingLikes(db) {
  if (!seedLikes || !CURRENT_USER_ID) {
    console.log('\n[4/6] Incoming likes: skipped');
    return;
  }
  const count = LIKE_SLOTS.end - LIKE_SLOTS.start + 1;
  console.log(`\n[4/6] Seeding ${count} incoming likes → ${CURRENT_USER_ID}...`);
  const ops = [];
  for (let n = LIKE_SLOTS.start; n <= LIKE_SLOTS.end; n++) {
    const fromUserId = testUserId(n);
    const type = n <= LIKE_NORMAL_END ? 'like' : 'super_like';
    const likeId = `${fromUserId}_${CURRENT_USER_ID}`;
    const likeDoc = generateLikeDoc(fromUserId, CURRENT_USER_ID, type);
    ops.push({ type: 'set', ref: db.collection('likes').doc(likeId), data: likeDoc });
  }
  if (!isDryRun) {
    await commitBatches(db, ops, 'likes');
    console.log(`  ✓ ${ops.length} like documents written`);
    console.log(`  (001..0${LIKE_NORMAL_END} = 'like', 0${LIKE_NORMAL_END + 1}..0${LIKE_SLOTS.end} = 'super_like')`);
  } else {
    console.log(`  [DRY-RUN] Would write ${ops.length} like docs`);
    const example = generateLikeDoc(testUserId(LIKE_SLOTS.start), CURRENT_USER_ID, 'like');
    delete example.createdAt;
    console.log('  Example like:', JSON.stringify({ ...example, createdAt: '<serverTimestamp>' }));
  }
}

async function seedExistingMatches(db) {
  if (!seedMatches || !CURRENT_USER_ID) {
    console.log('\n[5/6] Existing matches: skipped');
    return;
  }
  const count = MATCH_SLOTS.end - MATCH_SLOTS.start + 1;
  console.log(`\n[5/6] Seeding ${count} existing matches with ${CURRENT_USER_ID}...`);
  const ops = [];
  const matchIds = [];

  for (let n = MATCH_SLOTS.start; n <= MATCH_SLOTS.end; n++) {
    const testId = testUserId(n);
    const matchId = generateMatchId(CURRENT_USER_ID, testId);
    const score = 50 + ((n * 7) % 46); // 50-95
    const matchDoc = generateMatchDoc(matchId, CURRENT_USER_ID, testId, score);

    if (seedChatPreviews) {
      const msgIdx = (n - MATCH_SLOTS.start) % SAFE_CHAT_MESSAGES.length;
      matchDoc.lastMessagePreview = SAFE_CHAT_MESSAGES[msgIdx];
      matchDoc.lastMessageAt = admin.firestore.FieldValue.serverTimestamp();
    }

    ops.push({ type: 'set', ref: db.collection('matches').doc(matchId), data: matchDoc });
    matchIds.push(matchId);
  }

  if (!isDryRun) {
    await commitBatches(db, ops, 'matches');
    console.log(`  ✓ ${ops.length} match documents written`);
    console.log('  Match IDs:', matchIds.join(', '));
  } else {
    console.log(`  [DRY-RUN] Would write ${ops.length} match docs`);
    const exampleId = matchIds[0];
    const exampleScore = 50 + (MATCH_SLOTS.start * 7) % 46;
    console.log('  Example match:', JSON.stringify({
      id: exampleId,
      users: [CURRENT_USER_ID, testUserId(MATCH_SLOTS.start)],
      compatibilityScore: exampleScore,
      createdAt: '<serverTimestamp>',
      lastMessageAt: seedChatPreviews ? '<serverTimestamp>' : null,
      lastMessagePreview: seedChatPreviews ? SAFE_CHAT_MESSAGES[0] : '',
      active: true,
    }));
  }
}

async function doSeedPasses(db) {
  if (!seedPasses || !CURRENT_USER_ID) {
    console.log('\n[6/6] Passes: skipped');
    return;
  }
  const count = PASS_SLOTS.end - PASS_SLOTS.start + 1;
  console.log(`\n[6/6] Seeding ${count} passes by ${CURRENT_USER_ID}...`);
  const ops = [];
  for (let n = PASS_SLOTS.start; n <= PASS_SLOTS.end; n++) {
    const passedId = testUserId(n);
    ops.push({
      type: 'set',
      ref: db.collection('users').doc(CURRENT_USER_ID).collection('passes').doc(passedId),
      data: {
        passedUserId: passedId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    });
  }
  if (!isDryRun) {
    await commitBatches(db, ops, 'passes');
    console.log(`  ✓ ${ops.length} pass documents written under users/${CURRENT_USER_ID}/passes/`);
  } else {
    console.log(`  [DRY-RUN] Would write ${ops.length} pass docs under users/${CURRENT_USER_ID}/passes/`);
  }
}

// ── Validation checklist ──────────────────────────────────────────────────────

async function printValidationChecklist(db) {
  if (isDryRun) return;
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║                    Validation Checklist                     ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log('  Verifying sample documents...\n');

  const sampleId = testUserId(1);

  try {
    const userSnap = await db.collection('users').doc(sampleId).get();
    if (userSnap.exists) {
      const d = userSnap.data();
      console.log(`  ✓ users/${sampleId} exists`);
      console.log(`    geoHash       : ${d.geoHash || '(missing!)'}`);
      console.log(`    accountStatus : ${d.accountStatus}`);
      console.log(`    isOnline      : ${d.isOnline}`);
      console.log(`    isTestUser    : ${d.isTestUser}`);
      console.log(`    identity      : ${d.identity}`);
    } else {
      console.log(`  ✗ users/${sampleId} NOT found`);
    }
  } catch (e) {
    console.log(`  ✗ Error reading users/${sampleId}: ${e.message}`);
  }

  try {
    const locSnap = await db.collection('users').doc(sampleId).collection('private').doc('location').get();
    if (locSnap.exists) {
      const d = locSnap.data();
      console.log(`  ✓ users/${sampleId}/private/location exists`);
      console.log(`    GeoPoint      : lat=${d.location?.latitude?.toFixed(5)} lng=${d.location?.longitude?.toFixed(5)}`);
    } else {
      console.log(`  ✗ users/${sampleId}/private/location NOT found`);
    }
  } catch (e) {
    console.log(`  ✗ Error reading location doc: ${e.message}`);
  }

  try {
    const metaSnap = await db.collection('test_seed_batches').doc(BATCH_NAME).get();
    console.log(metaSnap.exists
      ? `  ✓ test_seed_batches/${BATCH_NAME} exists`
      : `  ✗ test_seed_batches/${BATCH_NAME} NOT found`);
  } catch (e) {
    console.log(`  ✗ Error reading metadata: ${e.message}`);
  }

  console.log('\n  Manual verification steps:');
  console.log('  1. Firebase Console → Firestore → users → confirm test_seoul_001 to test_seoul_100 exist');
  console.log('  2. Confirm users/test_seoul_001/private/location has GeoPoint');
  console.log(`  3. App: Discovery feed should show SeoulTest001..100 (they are public/active)`);
  if (seedLikes && CURRENT_USER_ID) {
    console.log(`  4. App: Like any SeoulTest001..030 back → Cloud Function should create a match`);
  }
  if (seedMatches && CURRENT_USER_ID) {
    console.log(`  5. App: Messages tab should show ${MATCH_SLOTS.end - MATCH_SLOTS.start + 1} conversations`);
  }
  if (seedPasses && CURRENT_USER_ID) {
    console.log(`  6. App: SeoulTest036..040 should NOT appear in discovery (they are passed)`);
  }
  if (seedChatPreviews) {
    console.log(`  7. App: Messages tab tiles should display the synthetic preview text`);
  }
  console.log('');
}

// ── Firebase initialization ───────────────────────────────────────────────────

function initFirebase() {
  const appOptions = {};

  if (SERVICE_ACCOUNT) {
    try {
      const serviceAccount = require(require('path').resolve(SERVICE_ACCOUNT));
      appOptions.credential = admin.credential.cert(serviceAccount);
      appOptions.projectId  = serviceAccount.project_id;
    } catch (e) {
      console.error(`[ERROR] Could not load service account from ${SERVICE_ACCOUNT}: ${e.message}`);
      process.exit(1);
    }
  } else {
    appOptions.credential = admin.credential.applicationDefault();
  }

  if (DATABASE_URL) {
    appOptions.databaseURL = DATABASE_URL;
  }

  admin.initializeApp(appOptions);

  const db = admin.firestore();
  const rtdb = DATABASE_URL ? admin.database() : null;
  return { db, rtdb };
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  if (!isDryRun && !confirmed) {
    console.error(`\n[ERROR] Missing or incorrect --confirm argument.`);
    console.error(`  To write data, pass:  --confirm ${BATCH_NAME}`);
    console.error(`  To dry-run only, pass: --dry-run`);
    process.exit(1);
  }

  if ((seedLikes || seedMatches || seedPasses || seedChatPreviews) && !CURRENT_USER_ID) {
    console.error('\n[ERROR] --seed-incoming-likes / --seed-existing-matches / --seed-passes / --seed-chat-previews');
    console.error('  require CURRENT_USER_ID to be set.');
    console.error('  Set it via: CURRENT_USER_ID=<your-uid> node ...');
    process.exit(1);
  }

  if (seedChatPreviews && !seedMatches) {
    console.warn('\n[WARN] --seed-chat-previews is only effective when --seed-existing-matches is also passed.');
    console.warn('  Chat previews will be applied to newly-created match documents.');
  }

  // Dry-run: print plan and sample data without initializing Firebase at all.
  // No credentials are required for dry-run.
  if (isDryRun) {
    printPlan(null, null);
    // Show sample user data (uses admin.firestore.Timestamp static class — no init needed)
    await seedUsers(null);
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('  DRY-RUN COMPLETE — No data was written.');
    console.log('  To write: node phase8_1_seoul_seed.js --confirm phase8_1_seoul_001');
    console.log('═══════════════════════════════════════════════════════════════\n');
    process.exit(0);
  }

  const { db, rtdb } = initFirebase();

  printPlan(db, rtdb);

  console.log('\n  ⚠  Writing to Firebase in 3 seconds... Press Ctrl+C to abort.');
  await new Promise(r => setTimeout(r, 3000));

  try {
    await seedUsers(db);
    await seedRtdb(rtdb);
    await seedMetadata(db);
    await seedIncomingLikes(db);
    await seedExistingMatches(db);
    await doSeedPasses(db);
    await printValidationChecklist(db);

    console.log('╔══════════════════════════════════════════════════════════════╗');
    console.log('║                    Seed Complete ✓                          ║');
    console.log('╚══════════════════════════════════════════════════════════════╝');
    console.log(`  Batch: ${BATCH_NAME}`);
    console.log(`  To clean up: node phase8_1_seoul_cleanup.js --confirm ${BATCH_NAME}\n`);
    process.exit(0);
  } catch (err) {
    console.error('\n[FATAL] Seed failed:', err);
    process.exit(1);
  }
}

main();
