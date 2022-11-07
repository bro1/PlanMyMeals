import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Wishlist extends StatefulWidget {
  Wishlist({ super.key });

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Some Day / Wishlist"),
        ));

  }
}