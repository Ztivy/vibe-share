import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';

class StripeService {
  // ⚠️ Solo para demo — nunca exponer secret key en producción
  static const _publishableKey = '';
  static const _secretKey = '';

  static void init() {
    Stripe.publishableKey = _publishableKey;
  }

  final _dio = Dio();

  Future<bool> iniciarPago() async {
    try {
      // 1. Crear PaymentIntent desde el cliente (solo demo)
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': '5900',
          'currency': 'mxn',
          'payment_method_types[]': 'card',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final clientSecret = response.data['client_secret'] as String;

      // 2. Inicializar payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VibeShare Premium',
          style: ThemeMode.system,
        ),
      );

      // 3. Mostrar sheet nativo de Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Pago exitoso — activar premium en Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .update({'esPremium': true});
      }

      return true;
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        print('Stripe error: ${e.error.localizedMessage}');
      }
      return false;
    } catch (e) {
      print('Error pago: $e');
      return false;
    }
  }
}