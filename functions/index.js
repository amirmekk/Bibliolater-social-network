const functions = require('firebase-functions');
const admin = require('firebase-admin');
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