const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { firestore } = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async (snapshot, context) => {
        console.log('Follower Created', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        // 1 - create followed user posts ref
        const followedUserPostsRef = admin.firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts');
        // 2 - create following user's timeline ref
        const timelinePostRef = admin.firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');
        // 3 - get followed user's posts 
        const querySnapshot = await followedUserPostsRef.get();
        // 4 - add each followed users posts to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostRef.doc(postId).set(postData);
            }
        });
    })

exports.onDeleteFollower = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onDelete(async (snapshot, context) => {
        console.log('Follower Deleted', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;
        // 1 - get all of the posts of the unfollowed user that exist in the timeline collection by owner id
        const timelinePostRef = admin.firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where('ownerId', '==', userId);
        const querySnapshot = await timelinePostRef.get();
        // 2 - delete those posts
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    })

// when a post is created add that post to every follower timeline

exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        console.log('Post Created', snapshot.id);
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1 - get all the followers of the post owner
        const userFollowers = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');
        const querySnapshot = await userFollowers.get();
        // add new post to each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;
            admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);
        });
    })



exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        console.log('Post Updated', snapshot.id);
        const postUpdated = change.after.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1 - get all the followers of the post owner
        const userFollowers = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');
        const querySnapshot = await userFollowers.get();
        // Update each post in each follower's timeline after a change
        querySnapshot.forEach(doc => {
            const followerId = doc.id;
            admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }
                })
        });
    })


exports.onDeletePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        console.log('Post Deleted', snapshot.id);
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1 - get all the followers of the post owner
        const userFollowers = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');
        const querySnapshot = await userFollowers.get();
        // Delete each post in each follower's timeline after a change
        querySnapshot.forEach(doc => {
            const followerId = doc.id;
            admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
                })
        });
    })