part of registration_view;

class _PhoneNumberField extends GetView<RegistrationController> {
  const _PhoneNumberField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.phoneNumber,
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.trim() == "")
          return "";
        else {
          if (value.length < 10)
            return 'Enter complete phone number of 10 digits.';
          if (value.length > 10) return 'Enter valid phone number';
        }
      },
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.phone,
            color: Colors.grey,
          ),
          hintText: "Phone Number"),
    );
  }
}