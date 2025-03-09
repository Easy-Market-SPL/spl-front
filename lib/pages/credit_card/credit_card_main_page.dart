import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spl_front/bloc/ui_management/payment/payment_bloc.dart';
import 'package:spl_front/models/ui/stripe/stripe_custom_response.dart';
import 'package:spl_front/services/gui/stripe/stripe_service.dart';

import '../../models/ui/credit_card/credit_card_model.dart';

class HomePageCreditCard extends StatelessWidget {
  const HomePageCreditCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PaymentCardModel> tarjetas = <PaymentCardModel>[];

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        actions: [
          IconButton(
              onPressed: () async {
                /*
                mostrarLoading(context);
                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context);
                 */
                mostrarAlerta(context, 'Hola', 'Mundo');
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            width: size.width,
            height: size.height,
            top: 200,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              physics: BouncingScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    final paymentBloc = BlocProvider.of<PaymentBloc>(context);
                    paymentBloc.add(OnSelectCard(tarjetas[index]));
                    Navigator.push(
                        context, navegateFadeIn(context, TarjetaPage()));
                  },
                  child: AbsorbPointer(
                    // Block the interaction with the card
                    child: Hero(
                      tag: tarjetas[index].cardNumber,
                      child: CreditCardWidget(
                        cardNumber: tarjetas[index].cardNumber,
                        expiryDate: tarjetas[index].expiryDate,
                        cardHolderName: tarjetas[index].cardHolderName,
                        cvvCode: tarjetas[index].cvv,
                        showBackView: false,
                        onCreditCardWidgetChange:
                            (creditCardBrand) {}, // Do nothing
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: TotalPayButton(),
          ),
        ],
      ),
    );
  }

  Route navegateFadeIn(BuildContext context, Widget page) {
    return PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child);
        });
  }
}

class TotalPayButton extends StatelessWidget {
  const TotalPayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentBloc = BlocProvider.of<PaymentBloc>(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Color(0xff03285a),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '${paymentBloc.state.paymentAmount} ${paymentBloc.state.currency}',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) => _BtnPay(state: state),
          ),
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  final PaymentState state;

  const _BtnPay({required this.state});
  @override
  Widget build(BuildContext context) {
    return state.activeCard
        ? buildCardButton(context)
        : buildAppleAndGooglePlay(context);
  }

  Widget buildCardButton(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 170,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.white,
      child: Row(
        children: [
          Icon(FontAwesomeIcons.solidCreditCard, color: Color(0xff03285a)),
          SizedBox(width: 10),
          Text('Pagar',
              style: TextStyle(color: Color(0xff03285a), fontSize: 20))
        ],
      ),
      onPressed: () async {
        mostrarLoading(context);
        final stripeService = StripeService();
        final amount = context.read<PaymentBloc>().state.paymentAmountString;
        final currency = context.read<PaymentBloc>().state.currency;

        final StripeCustomReponse resp =
            await stripeService.payWithExistingCard(
                amount: amount, currency: currency, card: state.card!);

        Navigator.pop(context);

        if (resp.ok) {
          mostrarAlerta(context, 'Tarjeta OK', 'Todo Correcto');
        } else {
          mostrarAlerta(context, 'Error', resp.msg!);
        }
      },
    );
  }

  Widget buildAppleAndGooglePlay(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 150,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.white,
      child: Row(
        children: [
          Icon(
              Platform.isAndroid
                  ? FontAwesomeIcons.google
                  : FontAwesomeIcons.apple,
              color: Color(0xff03285a)),
          SizedBox(width: 10),
          Text('Pay', style: TextStyle(color: Color(0xff03285a), fontSize: 20))
        ],
      ),
      onPressed: () {},
    );
  }
}

class TarjetaPage extends StatelessWidget {
  const TarjetaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tarjeta = context.read<PaymentBloc>().state.card!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        leading: IconButton(
            onPressed: () {
              final paymentBloc = BlocProvider.of<PaymentBloc>(context);
              paymentBloc.add(OnDeselectCard());
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Stack(
        children: [
          Container(),
          Hero(
            tag: tarjeta.cardNumber,
            child: CreditCardWidget(
              cardNumber: tarjeta.cardNumber,
              expiryDate: tarjeta.expiryDate,
              cardHolderName: tarjeta.cardHolderName,
              cvvCode: tarjeta.cvv,
              showBackView: false,
              onCreditCardWidgetChange: (creditCardBrand) {},
            ),
          ),
          Positioned(
            bottom: 0,
            child: TotalPayButton(),
          ),
        ],
      ),
    );
  }
}

class PagoCompletoPage extends StatelessWidget {
  const PagoCompletoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago Completado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.star, color: Colors.white54, size: 100),
            SizedBox(
              height: 20,
            ),
            Text('Pago Completado con Éxito', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

mostrarLoading(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
            title: Text('Espere por favor...'),
            content: LinearProgressIndicator(),
          ));
}

mostrarAlerta(BuildContext context, String titulo, String mensaje) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              MaterialButton(
                child: Text('Ok'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ));
}
