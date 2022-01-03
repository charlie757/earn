part of authentication_view;

class _IllustrationImage extends StatelessWidget {
  const _IllustrationImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.width,
      child: Image.asset(
        ImageVectorConstant.authenticationIllustration,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}