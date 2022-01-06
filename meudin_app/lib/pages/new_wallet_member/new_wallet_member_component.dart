import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/dtos/member_dto.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class NewWalletMemberComponent extends StatefulWidget {
  final Wallet currentWallet;
  final List<MemberDto> walletMembers;

  NewWalletMemberComponent(
      {required this.currentWallet, required this.walletMembers});

  @override
  _NewWalletMemberComponentState createState() =>
      _NewWalletMemberComponentState(currentWallet, walletMembers);
}

class _NewWalletMemberComponentState extends State<NewWalletMemberComponent> {
  final _formKey = GlobalKey<FormState>();
  final Wallet currentWallet;
  final List<MemberDto> membersMail;

  late TextEditingController _newMemberMailController;
  bool _loading = false;

  late UserService _userService;

  _NewWalletMemberComponentState(this.currentWallet, this.membersMail) {
    _userService = UserService();
    _newMemberMailController = TextEditingController();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo membro',
                  style: Styles.montTextTitle,
                ),
                Text(
                  currentWallet.name,
                  style: Styles.montSubText,
                ),
              ],
            ),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.times,
              color: Styles.mainTextColor,
              size: 22,
            ),
            onPressed: () {
              _goBack(false);
            },
          ),
        ],
      ),
    );
  }

  _goBack(bool refresh) {
    Navigator.pop(context, refresh);
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: TextFormField(
          style: TextStyle(color: Colors.grey.shade100),
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          maxLength: 50,
          controller: _newMemberMailController,
          validator: (value) {
            if (value!.isEmpty) {
              return Constants.getDefaultEmptyFieldMsg(context);
            }

            if ((!value.contains('.com') || !value.contains('@'))) {
              return Constants.getDefaultInvalidEmailMsg(context);
            }

            if (_isUserMail(value)) {
              return 'Digite o email de outro usuário';
            }

            if (_isAlreadyAdded(value)) {
              return 'Membro já adicionado';
            }

            return null;
          },
          decoration: Styles.getTextFieldDecorationUnderline('Email'),
        ),
      ),
    );
  }

  _isUserMail(String mail) {
    return (mail == UserService.currentUser!.email);
  }

  _isAlreadyAdded(String mail) {
    bool alreadyAdded = false;

    if (membersMail.isNotEmpty) {
      for (var element in membersMail) {
        if (element.email == mail) {
          alreadyAdded = true;
        }
      }
    }

    return alreadyAdded;
  }

  Future<void> _openLoginBottomSheet(String title, String message) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  _sendMemberInvitation() {
    setState(() {
      _loading = true;
    });

    String memberMail = _newMemberMailController.text;
    String walletId = currentWallet.id;

    _userService
        .addMemberToWallet(memberMail, walletId)
        .then((res) async {
      if (res.success) {
        String memberName = res.data;
        String walletName = currentWallet.name;

        String title = 'Sucesso!';
        String message = '$memberName adicionado à $walletName';

        setState(() {
          _loading = false;
        });

        await _openLoginBottomSheet(title, message);

        _goBack(true);
      } else {
        String title = 'Ops...';
        String message = res.errorMsg;

        setState(() {
          _loading = false;
        });

        _openLoginBottomSheet(title, message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(
                    width: double.infinity,
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text(
                      'Digite o email do membro',
                      style: Styles.montTextGrey,
                    ),
                  ),
                  _buildForm(),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!_loading) {
                        _sendMemberInvitation();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius,
                    ),
                  ),
                  child: Text(
                    'Convidar',
                    style: Styles.buttonTextStyle,
                  ),
                ),
              ),
            ),
            LoadingBlock(_loading),
          ],
        ),
      ),
    );
  }
}
