import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class NewMemebrInfoSheetComponent extends StatelessWidget {
  final bool isPtLanguage;

  NewMemebrInfoSheetComponent(this.isPtLanguage);

  String _getcontentText() {
    return this.isPtLanguage
        ? 'Você pode compartilhar sua carteira com outros usuarios, mas só você (dono da carteira) pode fazer isso. \n \n'
            'Digite o email do membro que deseja dar acesso à esta carteira. \n \n'
            'Os membros poderão incluir receitas, incluir/editar/excluir despesas e visualizar as transações feitas. \n \n'
            'A qualquer momento você pode remover o acesso do membro à esta carteira. \n \n'
        : 'You can share your wallet with other users, but only you (the wallet owner) can do this. \n \n'
            'Enter the email address of the member who wants to give access to this wallet. \n \n'
            'Members will be able to include revenues, include/edit/exclude expenses and view transactions made. \n \n'
            'At any time you can remove a member\'s access to this wallet.';
  }

  _closeDialog(BuildContext context) {
    Navigator.pop(context, 'Ok');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.mainBackgroundColor,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Colors.grey.shade800,
              size: 50,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _getcontentText(),
              style: TextStyle(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              textColor: Colors.deepPurple,
              onPressed: () {
                this._closeDialog(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
