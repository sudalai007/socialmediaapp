import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmediaapp/buttons/comment_button.dart';
import 'package:socialmediaapp/buttons/delete_button.dart';
import 'package:socialmediaapp/buttons/like_button.dart';
import 'package:socialmediaapp/components/comment.dart';
import 'package:socialmediaapp/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String time;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //comment Text Controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email!);
  }

  //toogle like
  void toogleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document in firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, add the user email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // If the post is now unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a commant
  void addComment(String commentText) {
    //Write the comment to firestore under the comment collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection('Comments')
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() //remeber to format this when displaying
    });
  }

  //Show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Add Comment'),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment.."),
              ),
              actions: [
                //cancel Button
                TextButton(
                    onPressed: () {
                      //pop box
                      Navigator.pop(context);

                      //clear controller
                      _commentTextController.clear();
                    },
                    child: Text("Cancel")),

                //post Button
                TextButton(
                    onPressed: () {
                      addComment(_commentTextController.text);

                      //pop box
                      Navigator.pop(context);

                      //clear controller
                      _commentTextController.clear();
                    },
                    child: Text("Post")),
              ],
            ));
  }

  //delete a post
  void deletePost() {
    //show a dialog box asking for confimation before deleting the post
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Post'),
              content: const Text('Are you sure you want to delete this post'),
              actions: [
                //Cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      //delete the comment from firestore first (If you only delete the post, the comment will still be stored in firestore)
                      final commentDocs = await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .collection('Comments')
                          .get();

                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("User Posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }
                      //then delete the post
                      FirebaseFirestore.instance
                          .collection("User Posts")
                          .doc(widget.postId)
                          .delete()
                          .then((value) => print("Post deleted"))
                          .catchError((error) =>
                              ("Print failed to delete post: $error"));

                      //dismiss the dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //message and user email

          //wall post
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //group of text(message + user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message
                  Text(widget.message),

                  SizedBox(height: 5),

                  //user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(" . ", style: TextStyle(color: Colors.grey[400])),
                      Text(widget.time,
                          style: TextStyle(color: Colors.grey[400]))
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              //delete Button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),
          //Like Button

          const SizedBox(
            width: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toogleLike),
                  const SizedBox(height: 5),

                  //like count
                  Text(widget.likes.length.toString(),
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 10),
              //comment
              Column(
                children: [
                  //comment button
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),

                  //like count
                  Text("0", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),
          //comments under the post
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //show loading circle if no data yet
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                    shrinkWrap: true, //for nested lists
                    physics: const NeverScrollableScrollPhysics(),
                    children: snapshot.data!.docs.map((doc) {
                      //get the comment
                      final CommentData = doc.data() as Map<String, dynamic>;

                      //return the comment
                      return Comment(
                        text: CommentData['CommentText'],
                        user: CommentData['CommentedBy'],
                        time: formatDate(CommentData['CommentTime']),
                      );
                    }).toList());
              })
        ],
      ),
    );
  }
}
