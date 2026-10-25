import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/data/repositories/bank_repository.dart';

/// Categories of supported financial institutions
enum BankCategory {
  egyptian,
  fintech,
  international,
}

/// Model representing a bank, neo-bank, or fintech app with bilingual names and logo asset.
class EgyptianBank {
  final String id;
  final String nameAr;
  final String nameEn;
  final String shortName;
  final String logoAsset;
  final String? logoUrl;
  final String? website;
  final String? swiftCode;
  final bool isPopular;
  final BankCategory category;

  const EgyptianBank({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.shortName,
    required this.logoAsset,
    this.logoUrl,
    this.website,
    this.swiftCode,
    this.isPopular = false,
    this.category = BankCategory.egyptian,
  });

  String get effectiveLogoUrl => (logoUrl != null &&
          logoUrl!.isNotEmpty &&
          !logoUrl!.contains('google.com/s2/favicons'))
      ? logoUrl!
      : 'https://mahfazati.runasp.net/images/banks/$id.png';

  /// Returns the clean bank name without parenthetical English abbreviations or marketing tags.
  /// E.g. 'البنك الأهلي المصري' instead of 'البنك الأهلي المصري (NBE)'
  /// E.g. 'Telda' instead of 'Telda App & Card'
  String cleanName(bool isAr) {
    if (isAr) {
      final stripped = nameAr.replaceAll(RegExp(r'\s*\([^)]*\)$'), '').trim();
      return stripped.isNotEmpty ? stripped : nameAr;
    } else {
      return nameEn.trim();
    }
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.trim().toLowerCase();
    return nameAr.toLowerCase().contains(q) ||
        nameEn.toLowerCase().contains(q) ||
        cleanName(true).toLowerCase().contains(q) ||
        cleanName(false).toLowerCase().contains(q) ||
        shortName.toLowerCase().contains(q) ||
        id.toLowerCase().contains(q) ||
        (swiftCode != null && swiftCode!.toLowerCase().contains(q));
  }
}

/// Comprehensive list of all Egyptian banks, top neo-banks, fintech apps, and international banks.
const List<EgyptianBank> kAllEgyptianBanks = [
  EgyptianBank(
    id: 'instapay',
    nameAr: 'إنستاباي (InstaPay)',
    nameEn: 'InstaPay Egypt',
    shortName: 'InstaPay',
    logoAsset: 'assets/icons/banks/instapay.png',
    website: 'https://instapay.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/instapay.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'nbe',
    nameAr: 'البنك الأهلي المصري (NBE)',
    nameEn: 'National Bank of Egypt',
    shortName: 'NBE',
    logoAsset: 'assets/icons/banks/nbe.png',
    website: 'https://www.nbe.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nbe.png',
    swiftCode: 'NBEGEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'misr',
    nameAr: 'بنك مصر (Banque Misr)',
    nameEn: 'Banque Misr',
    shortName: 'BM',
    logoAsset: 'assets/icons/banks/misr.png',
    website: 'https://www.banquemisr.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/misr.png',
    swiftCode: 'BMISEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'cib',
    nameAr: 'البنك التجاري الدولي (CIB)',
    nameEn: 'Commercial International Bank',
    shortName: 'CIB',
    logoAsset: 'assets/icons/banks/cib.png',
    website: 'https://www.cibeg.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/cib.png',
    swiftCode: 'CIBEEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'telda',
    nameAr: 'تيلدا (Telda)',
    nameEn: 'Telda',
    shortName: 'Telda',
    logoAsset: 'assets/icons/banks/telda.png',
    website: 'https://telda.app',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/telda.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'fawry',
    nameAr: 'فوري (myFawry)',
    nameEn: 'Fawry',
    shortName: 'Fawry',
    logoAsset: 'assets/icons/banks/fawry.png',
    website: 'https://fawry.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/fawry.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'redotpay',
    nameAr: 'ريدوت باي (RedotPay)',
    nameEn: 'RedotPay',
    shortName: 'RedotPay',
    logoAsset: 'assets/icons/banks/redotpay.png',
    website: 'https://redotpay.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/redotpay.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'egyptpost',
    nameAr: 'البريد المصري (Egypt Post)',
    nameEn: 'Egypt Post',
    shortName: 'Egypt Post',
    logoAsset: 'assets/icons/banks/egyptpost.png',
    website: 'https://egyptpost.org',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/egyptpost.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'meeza',
    nameAr: 'ميزة (Meeza)',
    nameEn: 'Meeza',
    shortName: 'Meeza',
    logoAsset: 'assets/icons/banks/meeza.png',
    website: 'https://meeza.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/meeza.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'tamara',
    nameAr: 'تمارا (Tamara)',
    nameEn: 'Tamara',
    shortName: 'Tamara',
    logoAsset: 'assets/icons/banks/tamara.png',
    website: 'https://tamara.co',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/tamara.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'tru',
    nameAr: 'ترو (TRU)',
    nameEn: 'TRU',
    shortName: 'TRU',
    logoAsset: 'assets/icons/banks/tru.png',
    website: 'https://trufinance.app',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/tru.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'valu',
    nameAr: 'ڤاليو (valU)',
    nameEn: 'valU',
    shortName: 'valU',
    logoAsset: 'assets/icons/banks/valu.png',
    website: 'https://valu.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/valu.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'tabby',
    nameAr: 'تابي (Tabby)',
    nameEn: 'Tabby',
    shortName: 'Tabby',
    logoAsset: 'assets/icons/banks/tabby.png',
    website: 'https://tabby.ai',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/tabby.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'thndr',
    nameAr: 'ثندر (Thndr)',
    nameEn: 'Thndr',
    shortName: 'Thndr',
    logoAsset: 'assets/icons/banks/thndr.png',
    website: 'https://thndr.app',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/thndr.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'wise',
    nameAr: 'وايز (Wise)',
    nameEn: 'Wise',
    shortName: 'Wise',
    logoAsset: 'assets/icons/banks/wise.png',
    website: 'https://wise.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/wise.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'revolut',
    nameAr: 'ريفولوت (Revolut)',
    nameEn: 'Revolut',
    shortName: 'Revolut',
    logoAsset: 'assets/icons/banks/revolut.png',
    website: 'https://revolut.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/revolut.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'payoneer',
    nameAr: 'بايونيير (Payoneer)',
    nameEn: 'Payoneer',
    shortName: 'Payoneer',
    logoAsset: 'assets/icons/banks/payoneer.png',
    website: 'https://payoneer.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/payoneer.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'paypal',
    nameAr: 'باي بال (PayPal)',
    nameEn: 'PayPal',
    shortName: 'PayPal',
    logoAsset: 'assets/icons/banks/paypal.png',
    website: 'https://paypal.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/paypal.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'pyypl',
    nameAr: 'بيبل (Pyypl)',
    nameEn: 'Pyypl',
    shortName: 'Pyypl',
    logoAsset: 'assets/icons/banks/pyypl.png',
    website: 'https://pyypl.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/pyypl.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'myfin',
    nameAr: 'ماي فين (MyFin)',
    nameEn: 'MyFin',
    shortName: 'MyFin',
    logoAsset: 'assets/icons/banks/myfin.png',
    website: 'https://myfin.bg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/myfin.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'paysera',
    nameAr: 'بايسيرا (Paysera Bank)',
    nameEn: 'Paysera',
    shortName: 'Paysera',
    logoAsset: 'assets/icons/banks/paysera.png',
    website: 'https://paysera.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/paysera.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'qnb',
    nameAr: 'بنك قطر الوطني (QNB)',
    nameEn: 'QNB AlAhli Egypt',
    shortName: 'QNB',
    logoAsset: 'assets/icons/banks/qnb.png',
    website: 'https://qnbalahli.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/qnb.png',
    swiftCode: 'QNBAEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'alex',
    nameAr: 'بنك الإسكندرية (AlexBank)',
    nameEn: 'Bank of Alexandria',
    shortName: 'AlexBank',
    logoAsset: 'assets/icons/banks/alex.png',
    website: 'https://alexbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/alex.png',
    swiftCode: 'ALEXEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'bdc',
    nameAr: 'بنك القاهرة (Banque du Caire)',
    nameEn: 'Banque du Caire',
    shortName: 'BdC',
    logoAsset: 'assets/icons/banks/bdc.png',
    website: 'https://bdc.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bdc.png',
    swiftCode: 'BCAIEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'adib',
    nameAr: 'مصرف أبوظبي الإسلامي (ADIB)',
    nameEn: 'Abu Dhabi Islamic Bank Egypt',
    shortName: 'ADIB',
    logoAsset: 'assets/icons/banks/adib.png',
    website: 'https://adib.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/adib.png',
    swiftCode: 'ABDIEGCA',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'hdb',
    nameAr: 'بنك التعمير والإسكان (HDB)',
    nameEn: 'Housing and Development Bank',
    shortName: 'HDB',
    logoAsset: 'assets/icons/banks/hdb.png',
    website: 'https://hdb-egy.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/hdb.png',
    swiftCode: 'HDBKEGCA',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'faisal',
    nameAr: 'بنك فيصل الإسلامي المصري',
    nameEn: 'Faisal Islamic Bank of Egypt',
    shortName: 'FIB',
    logoAsset: 'assets/icons/banks/faisal.png',
    website: 'https://faisalbank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/faisal.png',
    swiftCode: 'FIEGEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'hsbc',
    nameAr: 'إتش إس بي سي مصر (HSBC)',
    nameEn: 'HSBC Bank Egypt',
    shortName: 'HSBC',
    logoAsset: 'assets/icons/banks/hsbc.png',
    website: 'https://hsbc.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/faisal.png',
    swiftCode: 'EBBKEGCX',
    isPopular: true,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'alrajhi',
    nameAr: 'مصرف الراجحي (Al Rajhi Bank)',
    nameEn: 'Al Rajhi Bank (KSA)',
    shortName: 'Al Rajhi',
    logoAsset: 'assets/icons/banks/alrajhi.png',
    website: 'https://alrajhibank.com.sa',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/alrajhi.png',
    swiftCode: 'RJHISARI',
    isPopular: true,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'snb',
    nameAr: 'البنك الأهلي السعودي (SNB AlAhli)',
    nameEn: 'Saudi National Bank',
    shortName: 'SNB',
    logoAsset: 'assets/icons/banks/snb.png',
    website: 'https://alahli.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/snb.png',
    swiftCode: 'NCBKSARI',
    isPopular: true,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'mashreq',
    nameAr: 'بنك المشرق / مشرق نيو (Mashreq Neo)',
    nameEn: 'Mashreq Neo Digital Bank',
    shortName: 'Mashreq',
    logoAsset: 'assets/icons/banks/mashreq.png',
    website: 'https://mashreq.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/mashreq.png',
    swiftCode: 'MSHQEGCA',
    isPopular: true,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'monzo',
    nameAr: 'مونزو بنك (Monzo Bank)',
    nameEn: 'Monzo Bank UK',
    shortName: 'Monzo',
    logoAsset: 'assets/icons/banks/monzo.png',
    website: 'https://monzo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/monzo.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'n26',
    nameAr: 'إن 26 (N26 Bank)',
    nameEn: 'N26 Mobile Bank',
    shortName: 'N26',
    logoAsset: 'assets/icons/banks/n26.png',
    website: 'https://n26.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/n26.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'binance',
    nameAr: 'بينانس (Binance)',
    nameEn: 'Binance',
    shortName: 'Binance',
    logoAsset: 'assets/icons/banks/binance.png',
    website: 'https://binance.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/binance.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'credit_agricole',
    nameAr: 'كريدي أجريكول مصر (Crédit Agricole)',
    nameEn: 'Crédit Agricole Egypt',
    shortName: 'CAE',
    logoAsset: 'assets/icons/banks/credit_agricole.png',
    website: 'https://ca-egypt.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/credit_agricole.png',
    swiftCode: 'AGRIEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'enbd',
    nameAr: 'بنك الإمارات دبي الوطني (Emirates NBD)',
    nameEn: 'Emirates NBD Egypt',
    shortName: 'ENBD',
    logoAsset: 'assets/icons/banks/enbd.png',
    website: 'https://emiratesnbd.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/enbd.png',
    swiftCode: 'EBILEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'adcb',
    nameAr: 'بنك أبوظبي التجاري مصر (ADCB)',
    nameEn: 'Abu Dhabi Commercial Bank Egypt',
    shortName: 'ADCB',
    logoAsset: 'assets/icons/banks/adcb.png',
    website: 'https://adcb.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/adcb.png',
    swiftCode: 'ADCBEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'abk',
    nameAr: 'البنك الأهلي الكويتي مصر (ABK)',
    nameEn: 'Al Ahli Bank of Kuwait Egypt',
    shortName: 'ABK',
    logoAsset: 'assets/icons/banks/abk.png',
    website: 'https://abkegypt.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/abk.png',
    swiftCode: 'ABKIEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'nbk',
    nameAr: 'بنك الكويت الوطني (NBK)',
    nameEn: 'National Bank of Kuwait Egypt',
    shortName: 'NBK',
    logoAsset: 'assets/icons/banks/nbk.png',
    website: 'https://nbk.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nbk.png',
    swiftCode: 'NBKKEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'aaib',
    nameAr: 'البنك العربي الأفريقي الدولي (AAIB)',
    nameEn: 'Arab African International Bank',
    shortName: 'AAIB',
    logoAsset: 'assets/icons/banks/aaib.png',
    website: 'https://aaib.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/aaib.png',
    swiftCode: 'ARAIEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'arab_bank',
    nameAr: 'البنك العربي مصر (Arab Bank)',
    nameEn: 'Arab Bank Egypt',
    shortName: 'Arab Bank',
    logoAsset: 'assets/icons/banks/arab_bank.png',
    website: 'https://arabbank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/arab_bank.png',
    swiftCode: 'ARABEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'fab',
    nameAr: 'بنك أبوظبي الأول مصر (FABMISR)',
    nameEn: 'First Abu Dhabi Bank Misr',
    shortName: 'FABMISR',
    logoAsset: 'assets/icons/banks/fab.png',
    website: 'https://fabmisr.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/fab.png',
    swiftCode: 'NBADEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'attijariwafa',
    nameAr: 'التجاري وفا بنك مصر (Attijariwafa Bank)',
    nameEn: 'Attijariwafa Bank Egypt',
    shortName: 'Attijariwafa',
    logoAsset: 'assets/icons/banks/attijariwafa.png',
    website: 'https://attijariwafabank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/attijariwafa.png',
    swiftCode: 'WAFAEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'saib',
    nameAr: 'بنك الشركة المصرفية العربية الدولية (saib)',
    nameEn: 'Société Arabe Internationale de Banque',
    shortName: 'saib',
    logoAsset: 'assets/icons/banks/saib.png',
    website: 'https://saib.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/saib.png',
    swiftCode: 'SBNKEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'egbank',
    nameAr: 'البنك المصري الخليجي (EGBANK)',
    nameEn: 'Egyptian Gulf Bank',
    shortName: 'EGBANK',
    logoAsset: 'assets/icons/banks/egbank.png',
    website: 'https://eg-bank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/egbank.png',
    swiftCode: 'EGGBEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'scb',
    nameAr: 'بنك قناة السويس (SCB)',
    nameEn: 'Suez Canal Bank',
    shortName: 'SCB',
    logoAsset: 'assets/icons/banks/scb.png',
    website: 'https://scbank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/scb.png',
    swiftCode: 'SUCAEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'ub',
    nameAr: 'المصرف المتحد (The United Bank)',
    nameEn: 'The United Bank of Egypt',
    shortName: 'UB',
    logoAsset: 'assets/icons/banks/ub.png',
    website: 'https://theubeg.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ub.png',
    swiftCode: 'UBOEEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'albaraka',
    nameAr: 'بنك البركة مصر',
    nameEn: 'Al Baraka Bank Egypt',
    shortName: 'Al Baraka',
    logoAsset: 'assets/icons/banks/albaraka.png',
    website: 'https://albaraka.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/albaraka.png',
    swiftCode: 'ABRKEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'idb',
    nameAr: 'بنك التنمية الصناعية (IDB)',
    nameEn: 'Industrial Development Bank',
    shortName: 'IDB',
    logoAsset: 'assets/icons/banks/idb.png',
    website: 'https://idb.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/albaraka.png',
    swiftCode: 'IDBKEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'ealb',
    nameAr: 'البنك العقاري المصري العربي',
    nameEn: 'Egyptian Arab Land Bank',
    shortName: 'EALB',
    logoAsset: 'assets/icons/banks/ealb.png',
    website: 'https://eal-bank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ealb.png',
    swiftCode: 'ARLBEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'abe',
    nameAr: 'البنك الزراعي المصري',
    nameEn: 'Agricultural Bank of Egypt',
    shortName: 'ABE',
    logoAsset: 'assets/icons/banks/abe.png',
    website: 'https://abe.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/abe.png',
    swiftCode: 'PBDCEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'ebank',
    nameAr: 'البنك المصري لتنمية الصادرات (EBank)',
    nameEn: 'Export Development Bank of Egypt',
    shortName: 'EBank',
    logoAsset: 'assets/icons/banks/ebank.png',
    website: 'https://ebank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ealb.png',
    swiftCode: 'EXDEEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'aibank',
    nameAr: 'بنك نكست (aiBANK)',
    nameEn: 'Bank NXT (formerly aiBANK)',
    shortName: 'Bank NXT',
    logoAsset: 'assets/icons/banks/aibank.png',
    website: 'https://banknxt.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/aibank.png',
    swiftCode: 'AINBEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'abc',
    nameAr: 'بنك ABC مصر',
    nameEn: 'Bank ABC Egypt',
    shortName: 'Bank ABC',
    logoAsset: 'assets/icons/banks/abc.png',
    website: 'https://bank-abc.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/abc.png',
    swiftCode: 'ABCOEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'midbank',
    nameAr: 'ميد بنك (MIDBANK)',
    nameEn: 'MIDBANK Egypt',
    shortName: 'MIDBANK',
    logoAsset: 'assets/icons/banks/midbank.png',
    website: 'https://midbank.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/abc.png',
    swiftCode: 'MIDBEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'aib',
    nameAr: 'المصرف العربي الدولي (AIB)',
    nameEn: 'Arab International Bank',
    shortName: 'AIB',
    logoAsset: 'assets/icons/banks/aib.png',
    website: 'https://aib.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/aib.png',
    swiftCode: 'ARIBEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'sc',
    nameAr: 'بنك ستاندرد تشارترد مصر',
    nameEn: 'Standard Chartered Bank Egypt',
    shortName: 'Standard Chartered',
    logoAsset: 'assets/icons/banks/sc.png',
    website: 'https://sc.com/eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/sc.png',
    swiftCode: 'SCBLUS33',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'citi',
    nameAr: 'سيتي بنك مصر (Citibank)',
    nameEn: 'Citibank Egypt',
    shortName: 'Citi',
    logoAsset: 'assets/icons/banks/citi.png',
    website: 'https://citibank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/sc.png',
    swiftCode: 'CITIEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'nasser',
    nameAr: 'بنك ناصر الاجتماعي',
    nameEn: 'Nasser Social Bank',
    shortName: 'Nasser Bank',
    logoAsset: 'assets/icons/banks/nasser.png',
    website: 'https://nsb.gov.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nasser.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'klivvr',
    nameAr: 'كليفر (Klivvr)',
    nameEn: 'Klivvr',
    shortName: 'Klivvr',
    logoAsset: 'assets/icons/banks/klivvr.png',
    website: 'https://klivvr.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nasser.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'khazna',
    nameAr: 'خزنة (Khazna)',
    nameEn: 'Khazna',
    shortName: 'Khazna',
    logoAsset: 'assets/icons/banks/khazna.png',
    website: 'https://khazna.app',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/khazna.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'kashat',
    nameAr: 'كاشات (Kashat)',
    nameEn: 'Kashat',
    shortName: 'Kashat',
    logoAsset: 'assets/icons/banks/kashat.png',
    website: 'https://kashat.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/kashat.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'souhoola',
    nameAr: 'سهولة (Souhoola)',
    nameEn: 'Souhoola',
    shortName: 'Souhoola',
    logoAsset: 'assets/icons/banks/souhoola.png',
    website: 'https://souhoola.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/souhoola.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'contact',
    nameAr: 'كونتكت (Contact)',
    nameEn: 'Contact Financial Services',
    shortName: 'Contact',
    logoAsset: 'assets/icons/banks/contact.png',
    website: 'https://contact.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/contact.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'skrill',
    nameAr: 'سكريل (Skrill)',
    nameEn: 'Skrill',
    shortName: 'Skrill',
    logoAsset: 'assets/icons/banks/skrill.png',
    website: 'https://skrill.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/skrill.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'klarna',
    nameAr: 'كلارنا (Klarna)',
    nameEn: 'Klarna',
    shortName: 'Klarna',
    logoAsset: 'assets/icons/banks/klarna.png',
    website: 'https://klarna.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/klarna.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'chime',
    nameAr: 'تشايم (Chime Bank)',
    nameEn: 'Chime',
    shortName: 'Chime',
    logoAsset: 'assets/icons/banks/chime.png',
    website: 'https://chime.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/chime.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'mercury',
    nameAr: 'ميركوري (Mercury Bank)',
    nameEn: 'Mercury',
    shortName: 'Mercury',
    logoAsset: 'assets/icons/banks/mercury.png',
    website: 'https://mercury.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/mercury.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'starling',
    nameAr: 'ستارلينج بنك (Starling Bank)',
    nameEn: 'Starling Bank UK',
    shortName: 'Starling',
    logoAsset: 'assets/icons/banks/starling.png',
    website: 'https://starlingbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/starling.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'bunq',
    nameAr: 'بنك بانك (bunq)',
    nameEn: 'bunq Digital Bank',
    shortName: 'bunq',
    logoAsset: 'assets/icons/banks/bunq.png',
    website: 'https://bunq.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bunq.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'dukascopy',
    nameAr: 'دوكاسكوبي (Dukascopy Bank)',
    nameEn: 'Dukascopy Swiss Bank',
    shortName: 'Dukascopy',
    logoAsset: 'assets/icons/banks/dukascopy.png',
    website: 'https://dukascopy.bank',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/dukascopy.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'westernunion',
    nameAr: 'ويسترن يونيون (Western Union)',
    nameEn: 'Western Union',
    shortName: 'Western Union',
    logoAsset: 'assets/icons/banks/westernunion.png',
    website: 'https://westernunion.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/westernunion.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'applecash',
    nameAr: 'آبل كاش (Apple Cash)',
    nameEn: 'Apple Cash',
    shortName: 'Apple Cash',
    logoAsset: 'assets/icons/banks/applecash.png',
    website: 'https://apple.com/apple-pay',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/applecash.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'riyad',
    nameAr: 'بنك الرياض (Riyad Bank)',
    nameEn: 'Riyad Bank (KSA)',
    shortName: 'Riyad Bank',
    logoAsset: 'assets/icons/banks/riyad.png',
    website: 'https://riyadbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/riyad.png',
    swiftCode: 'RIBLSARI',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'stcpay',
    nameAr: 'بنك إس تي سي (STC Bank)',
    nameEn: 'STC Bank (KSA)',
    shortName: 'STC Bank',
    logoAsset: 'assets/icons/banks/stcpay.png',
    website: 'https://stcbank.com.sa',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/stcpay.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'urpay',
    nameAr: 'يور باي (urpay السعودية)',
    nameEn: 'urpay',
    shortName: 'urpay',
    logoAsset: 'assets/icons/banks/urpay.png',
    website: 'https://urpay.com.sa',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/urpay.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'wio',
    nameAr: 'ويو بنك (Wio Bank الإمارات)',
    nameEn: 'Wio Digital Bank (UAE)',
    shortName: 'Wio',
    logoAsset: 'assets/icons/banks/wio.png',
    website: 'https://wio.io',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/wio.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'liv',
    nameAr: 'ليف بنك (Liv. Bank الإمارات)',
    nameEn: 'Liv. Digital Bank (UAE)',
    shortName: 'Liv',
    logoAsset: 'assets/icons/banks/liv.png',
    website: 'https://liv.me',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/liv.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'ila',
    nameAr: 'إلى بنك (ila Bank البحرين)',
    nameEn: 'ila Digital Bank (Bahrain)',
    shortName: 'ila',
    logoAsset: 'assets/icons/banks/ila.png',
    website: 'https://ilabank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ila.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'kfh',
    nameAr: 'بيت التمويل الكويتي (KFH بيتك)',
    nameEn: 'Kuwait Finance House',
    shortName: 'KFH',
    logoAsset: 'assets/icons/banks/kfh.png',
    website: 'https://kfh.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/kfh.png',
    swiftCode: 'KFHUKWKW',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'dib',
    nameAr: 'بنك دبي الإسلامي (DIB)',
    nameEn: 'Dubai Islamic Bank',
    shortName: 'DIB',
    logoAsset: 'assets/icons/banks/dib.png',
    website: 'https://dib.ae',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/dib.png',
    swiftCode: 'DUBIAEAD',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'bofa',
    nameAr: 'بنك أوف أمريكا (Bank of America)',
    nameEn: 'Bank of America',
    shortName: 'BofA',
    logoAsset: 'assets/icons/banks/bofa.png',
    website: 'https://bankofamerica.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bofa.png',
    swiftCode: 'BOFAUS3N',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'wellsfargo',
    nameAr: 'ويلز فارجو (Wells Fargo Bank)',
    nameEn: 'Wells Fargo',
    shortName: 'Wells Fargo',
    logoAsset: 'assets/icons/banks/wellsfargo.png',
    website: 'https://wellsfargo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/wellsfargo.png',
    swiftCode: 'WFBIUS6S',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'chase',
    nameAr: 'جي بي مورجان تشيس (Chase Bank)',
    nameEn: 'JPMorgan Chase (USA)',
    shortName: 'Chase',
    logoAsset: 'assets/icons/banks/chase.png',
    website: 'https://chase.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/chase.png',
    swiftCode: 'CHASUS33',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'barclays',
    nameAr: 'باركليز بنك (Barclays Bank)',
    nameEn: 'Barclays Bank (UK)',
    shortName: 'Barclays',
    logoAsset: 'assets/icons/banks/barclays.png',
    website: 'https://barclays.co.uk',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/barclays.png',
    swiftCode: 'BARCGB22',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'santander',
    nameAr: 'بنك سانتاندير (Santander Bank)',
    nameEn: 'Santander Bank',
    shortName: 'Santander',
    logoAsset: 'assets/icons/banks/santander.png',
    website: 'https://santander.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/santander.png',
    swiftCode: 'BSCHESMM',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'deutsche',
    nameAr: 'دويتشه بنك الألماني (Deutsche Bank)',
    nameEn: 'Deutsche Bank',
    shortName: 'Deutsche Bank',
    logoAsset: 'assets/icons/banks/deutsche.png',
    website: 'https://db.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/deutsche.png',
    swiftCode: 'DEUTDEDB',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'bnpparibas',
    nameAr: 'بي إن بي باريبا (BNP Paribas)',
    nameEn: 'BNP Paribas',
    shortName: 'BNP Paribas',
    logoAsset: 'assets/icons/banks/bnpparibas.png',
    website: 'https://mabanque.bnpparibas',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bnpparibas.png',
    swiftCode: 'BNPAFRPP',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'ahli_united',
    nameAr: 'البنك الأهلي المتحد (Ahli United Bank)',
    nameEn: 'Ahli United Bank',
    shortName: 'AUB',
    logoAsset: 'assets/icons/banks/ahli_united.png',
    website: 'https://ahliunited.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ahli_united.png',
    swiftCode: 'BKMEKWKW',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'bank_audi',
    nameAr: 'بنك عوده (Bank Audi)',
    nameEn: 'Bank Audi Egypt',
    shortName: 'Audi',
    logoAsset: 'assets/icons/banks/audi.png',
    website: 'https://bankaudi.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bank_audi.png',
    swiftCode: 'AUDBEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'blom',
    nameAr: 'بنك بلوم مصر (BLOM Bank)',
    nameEn: 'BLOM Bank Egypt',
    shortName: 'BLOM',
    logoAsset: 'assets/icons/banks/blom.png',
    website: 'https://blombankegypt.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/blom.png',
    swiftCode: 'MRBAEGCX',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'nbg',
    nameAr: 'البنك الأهلي اليوناني (National Bank of Greece)',
    nameEn: 'National Bank of Greece Egypt',
    shortName: 'NBG',
    logoAsset: 'assets/icons/banks/nbg.png',
    website: 'https://nbg.gr',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nbg.png',
    swiftCode: 'ETHNEGCA',
    isPopular: false,
    category: BankCategory.egyptian,
  ),
  EgyptianBank(
    id: 'bny_mellon',
    nameAr: 'بنك أوف نيويورك ميلون (BNY Mellon)',
    nameEn: 'The Bank of New York Mellon',
    shortName: 'BNY Mellon',
    logoAsset: 'assets/icons/banks/bny.png',
    website: 'https://bnymellon.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bny_mellon.png',
    swiftCode: 'IRVTUS3N',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'intesa',
    nameAr: 'إنتيسا سان باولو (Intesa Sanpaolo)',
    nameEn: 'Intesa Sanpaolo SPA',
    shortName: 'Intesa',
    logoAsset: 'assets/icons/banks/intesa.png',
    website: 'https://intesasanpaolo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/intesa.png',
    swiftCode: 'BCITITMM',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'credit_suisse',
    nameAr: 'كريدي سويس (Credit Suisse)',
    nameEn: 'Credit Suisse Group',
    shortName: 'Credit Suisse',
    logoAsset: 'assets/icons/banks/credit_suisse.png',
    website: 'https://credit-suisse.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/credit_suisse.png',
    swiftCode: 'CRESEGC1',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'mufg',
    nameAr: 'بنك إم يو إف جي الياباني (MUFG Bank)',
    nameEn: 'MUFG Bank Ltd',
    shortName: 'MUFG',
    logoAsset: 'assets/icons/banks/mufg.png',
    website: 'https://mufg.jp',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/mufg.png',
    swiftCode: 'BOTKJPJT',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'natixis',
    nameAr: 'بنك ناتيكسيس (Natixis)',
    nameEn: 'Natixis Corporate & Investment Banking',
    shortName: 'Natixis',
    logoAsset: 'assets/icons/banks/natixis.png',
    website: 'https://natixis.groupebpce.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/natixis.png',
    swiftCode: 'NATXFRPP',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'societe_generale',
    nameAr: 'سوسيتيه جنرال (Société Générale)',
    nameEn: 'Société Générale Bank',
    shortName: 'SocGen',
    logoAsset: 'assets/icons/banks/societe_generale.png',
    website: 'https://societegenerale.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/societe_generale.png',
    swiftCode: 'SOGEFRPP',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'goldman_sachs',
    nameAr: 'جولدمان ساكس (Goldman Sachs)',
    nameEn: 'The Goldman Sachs Group',
    shortName: 'Goldman Sachs',
    logoAsset: 'assets/icons/banks/goldman_sachs.png',
    website: 'https://goldmansachs.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/goldman_sachs.png',
    swiftCode: 'GSCOUS33',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'morgan_stanley',
    nameAr: 'مورجان ستانلي (Morgan Stanley)',
    nameEn: 'Morgan Stanley Wealth Management',
    shortName: 'Morgan Stanley',
    logoAsset: 'assets/icons/banks/morgan_stanley.png',
    website: 'https://morganstanley.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/morgan_stanley.png',
    swiftCode: 'MSCOUS33',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'ubs',
    nameAr: 'يو بي إس السويسري (UBS Bank)',
    nameEn: 'UBS Group AG',
    shortName: 'UBS',
    logoAsset: 'assets/icons/banks/ubs.png',
    website: 'https://ubs.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ubs.png',
    swiftCode: 'UBSWCHZH',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'halan',
    nameAr: 'حالا (MNT-Halan)',
    nameEn: 'MNT-Halan',
    shortName: 'Halan',
    logoAsset: 'assets/icons/banks/halan.png',
    website: 'https://halan.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/halan.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'blnk',
    nameAr: 'بيل كاش (Blnk)',
    nameEn: 'Blnk',
    shortName: 'Blnk',
    logoAsset: 'assets/icons/banks/blnk.png',
    website: 'https://blnk.ai',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/blnk.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'moneyfellows',
    nameAr: 'موني فيلوز (MoneyFellows)',
    nameEn: 'MoneyFellows',
    shortName: 'MoneyFellows',
    logoAsset: 'assets/icons/banks/moneyfellows.png',
    website: 'https://moneyfellows.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/moneyfellows.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'aman',
    nameAr: 'أمان (Aman SuperApp)',
    nameEn: 'Aman Financial Services',
    shortName: 'Aman',
    logoAsset: 'assets/icons/banks/aman.png',
    website: 'https://aman.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/aman.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'forsa',
    nameAr: 'فرصة (Forsa)',
    nameEn: 'Forsa',
    shortName: 'Forsa',
    logoAsset: 'assets/icons/banks/forsa.png',
    website: 'https://forsa.com.eg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/forsa.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'midotrade',
    nameAr: 'ميد تريد (Mido Trade)',
    nameEn: 'Mido Trade',
    shortName: 'Mido',
    logoAsset: 'assets/icons/banks/midotrade.png',
    website: 'https://midotrade.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/midotrade.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'alinma',
    nameAr: 'مصرف الإنماء (Alinma Bank)',
    nameEn: 'Alinma Bank (KSA)',
    shortName: 'Alinma',
    logoAsset: 'assets/icons/banks/alinma.png',
    website: 'https://alinma.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/alinma.png',
    swiftCode: 'INMASARI',
    isPopular: true,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'albilad',
    nameAr: 'بنك البلاد (Bank Albilad)',
    nameEn: 'Bank Albilad (KSA)',
    shortName: 'Albilad',
    logoAsset: 'assets/icons/banks/albilad.png',
    website: 'https://bankalbilad.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/albilad.png',
    swiftCode: 'ALBISARI',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'sab',
    nameAr: 'البنك السعودي الأول (SAB)',
    nameEn: 'Saudi Awwal Bank',
    shortName: 'SAB',
    logoAsset: 'assets/icons/banks/sab.png',
    website: 'https://sab.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/sab.png',
    swiftCode: 'SABBSARI',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'aljazira',
    nameAr: 'بنك الجزيرة (Bank AlJazira)',
    nameEn: 'Bank AlJazira (KSA)',
    shortName: 'AlJazira',
    logoAsset: 'assets/icons/banks/aljazira.png',
    website: 'https://baj.com.sa',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/aljazira.png',
    swiftCode: 'BJAZSARI',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'boubyan',
    nameAr: 'بنك بوبيان (Boubyan Bank)',
    nameEn: 'Boubyan Bank (Kuwait)',
    shortName: 'Boubyan',
    logoAsset: 'assets/icons/banks/boubyan.png',
    website: 'https://boubyan.bankboubyan.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/boubyan.png',
    swiftCode: 'BOUBIEGC',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'gulfbank',
    nameAr: 'بنك الخليج (Gulf Bank)',
    nameEn: 'Gulf Bank Kuwait',
    shortName: 'Gulf Bank',
    logoAsset: 'assets/icons/banks/gulfbank.png',
    website: 'https://e-gulfbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/gulfbank.png',
    swiftCode: 'GULFKWKW',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'burgan',
    nameAr: 'بنك برقان (Burgan Bank)',
    nameEn: 'Burgan Bank (Kuwait)',
    shortName: 'Burgan',
    logoAsset: 'assets/icons/banks/burgan.png',
    website: 'https://burgan.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/burgan.png',
    swiftCode: 'BURGKWKW',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'warba',
    nameAr: 'بنك وربة (Warba Bank)',
    nameEn: 'Warba Bank (Kuwait)',
    shortName: 'Warba',
    logoAsset: 'assets/icons/banks/warba.png',
    website: 'https://warbabank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/warba.png',
    swiftCode: 'WARBKWKW',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'rakbank',
    nameAr: 'بنك رأس الخيمة الوطني (RAKBANK)',
    nameEn: 'RAKBANK (UAE)',
    shortName: 'RAKBANK',
    logoAsset: 'assets/icons/banks/rakbank.png',
    website: 'https://rakbank.ae',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/rakbank.png',
    swiftCode: 'RAKBUS33',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'sib',
    nameAr: 'مصرف الشارقة الإسلامي (SIB)',
    nameEn: 'Sharjah Islamic Bank',
    shortName: 'SIB',
    logoAsset: 'assets/icons/banks/sib.png',
    website: 'https://sib.ae',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/sib.png',
    swiftCode: 'SHARAEAD',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'qib',
    nameAr: 'مصرف قطر الإسلامي (QIB)',
    nameEn: 'Qatar Islamic Bank',
    shortName: 'QIB',
    logoAsset: 'assets/icons/banks/qib.png',
    website: 'https://qib.com.qa',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/qib.png',
    swiftCode: 'QIBKQAQA',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'dohabank',
    nameAr: 'بنك الدوحة (Doha Bank)',
    nameEn: 'Doha Bank',
    shortName: 'Doha Bank',
    logoAsset: 'assets/icons/banks/dohabank.png',
    website: 'https://dohabank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/dohabank.png',
    swiftCode: 'DOHBQAQA',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'rayan',
    nameAr: 'مصرف الريان (Masraf Al Rayan)',
    nameEn: 'Masraf Al Rayan (Qatar)',
    shortName: 'Al Rayan',
    logoAsset: 'assets/icons/banks/rayan.png',
    website: 'https://alrayan.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/rayan.png',
    swiftCode: 'ARYNQAQA',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'muscat',
    nameAr: 'بنك مسقط (Bank Muscat)',
    nameEn: 'Bank Muscat (Oman)',
    shortName: 'Bank Muscat',
    logoAsset: 'assets/icons/banks/muscat.png',
    website: 'https://bankmuscat.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/muscat.png',
    swiftCode: 'BMUSOMMX',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'nbb',
    nameAr: 'بنك البحرين الوطني (NBB)',
    nameEn: 'National Bank of Bahrain',
    shortName: 'NBB',
    logoAsset: 'assets/icons/banks/nbb.png',
    website: 'https://nbbonline.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nbb.png',
    swiftCode: 'NBOBBMBA',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'bbk',
    nameAr: 'بنك البحرين والكويت (BBK)',
    nameEn: 'Bank of Bahrain and Kuwait',
    shortName: 'BBK',
    logoAsset: 'assets/icons/banks/bbk.png',
    website: 'https://bbkonline.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bbk.png',
    swiftCode: 'BBKUUS33',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'etihad',
    nameAr: 'بنك الاتحاد (Bank al Etihad)',
    nameEn: 'Bank al Etihad (Jordan)',
    shortName: 'Etihad',
    logoAsset: 'assets/icons/banks/etihad.png',
    website: 'https://bankaletihad.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/etihad.png',
    swiftCode: 'ETIHEGCX',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'housingbank',
    nameAr: 'بنك الإسكان للتجارة والتمويل',
    nameEn: 'The Housing Bank (Jordan)',
    shortName: 'HBTF',
    logoAsset: 'assets/icons/banks/housingbank.png',
    website: 'https://hbtf.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/housingbank.png',
    swiftCode: 'HBTFJOA2',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'bbva',
    nameAr: 'بنك بي بي في إيه (BBVA)',
    nameEn: 'Banco Bilbao Vizcaya Argentaria',
    shortName: 'BBVA',
    logoAsset: 'assets/icons/banks/bbva.png',
    website: 'https://bbva.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bbva.png',
    swiftCode: 'BBVAESMM',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'ing',
    nameAr: 'بنك آي إن جي الهولندي (ING)',
    nameEn: 'ING Group (Netherlands)',
    shortName: 'ING',
    logoAsset: 'assets/icons/banks/ing.png',
    website: 'https://ing.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ing.png',
    swiftCode: 'INGBNL2A',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'rabobank',
    nameAr: 'بنك رابوبنك (Rabobank)',
    nameEn: 'Rabobank (Netherlands)',
    shortName: 'Rabobank',
    logoAsset: 'assets/icons/banks/rabobank.png',
    website: 'https://rabobank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/rabobank.png',
    swiftCode: 'RABONL2U',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'abnamro',
    nameAr: 'بنك إيه بي إن آمرو (ABN AMRO)',
    nameEn: 'ABN AMRO Bank',
    shortName: 'ABN AMRO',
    logoAsset: 'assets/icons/banks/abnamro.png',
    website: 'https://abnamro.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/abnamro.png',
    swiftCode: 'ABNANL2A',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'nordea',
    nameAr: 'بنك نورديا (Nordea Bank)',
    nameEn: 'Nordea Bank (Nordics)',
    shortName: 'Nordea',
    logoAsset: 'assets/icons/banks/nordea.png',
    website: 'https://nordea.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nordea.png',
    swiftCode: 'NDEASESS',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'commerzbank',
    nameAr: 'كوميرز بنك الألماني (Commerzbank)',
    nameEn: 'Commerzbank AG',
    shortName: 'Commerzbank',
    logoAsset: 'assets/icons/banks/commerzbank.png',
    website: 'https://commerzbank.de',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/commerzbank.png',
    swiftCode: 'COBADEFF',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'lloyds',
    nameAr: 'بنك لويدز البريطاني (Lloyds Bank)',
    nameEn: 'Lloyds Bank (UK)',
    shortName: 'Lloyds',
    logoAsset: 'assets/icons/banks/lloyds.png',
    website: 'https://lloydsbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/lloyds.png',
    swiftCode: 'LOYDGB2L',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'natwest',
    nameAr: 'بنك نات ويست (NatWest)',
    nameEn: 'National Westminster Bank',
    shortName: 'NatWest',
    logoAsset: 'assets/icons/banks/natwest.png',
    website: 'https://natwest.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/natwest.png',
    swiftCode: 'NWBKGB2L',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'rbc',
    nameAr: 'رويال بنك أوف كندا (RBC)',
    nameEn: 'Royal Bank of Canada',
    shortName: 'RBC',
    logoAsset: 'assets/icons/banks/rbc.png',
    website: 'https://rbc.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/rbc.png',
    swiftCode: 'ROYCCAT2',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'td',
    nameAr: 'تي دي بنك الكندي (TD Bank)',
    nameEn: 'TD Bank Financial Group',
    shortName: 'TD Bank',
    logoAsset: 'assets/icons/banks/td.png',
    website: 'https://td.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/td.png',
    swiftCode: 'TDOMCAT3',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'scotiabank',
    nameAr: 'سكوشيا بنك (Scotiabank)',
    nameEn: 'The Bank of Nova Scotia',
    shortName: 'Scotiabank',
    logoAsset: 'assets/icons/banks/scotiabank.png',
    website: 'https://scotiabank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/scotiabank.png',
    swiftCode: 'NOSCCATT',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'bmo',
    nameAr: 'بنك أوف مونتريال (BMO)',
    nameEn: 'Bank of Montreal',
    shortName: 'BMO',
    logoAsset: 'assets/icons/banks/bmo.png',
    website: 'https://bmo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bmo.png',
    swiftCode: 'BOFMCAM2',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'cba',
    nameAr: 'كومنولث بنك الأسترالي (CBA)',
    nameEn: 'Commonwealth Bank of Australia',
    shortName: 'CBA',
    logoAsset: 'assets/icons/banks/cba.png',
    website: 'https://commbank.com.au',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/cba.png',
    swiftCode: 'CTBAAU2S',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'anz',
    nameAr: 'بنك إيه إن زد (ANZ Bank)',
    nameEn: 'Australia and New Zealand Banking',
    shortName: 'ANZ',
    logoAsset: 'assets/icons/banks/anz.png',
    website: 'https://anz.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/anz.png',
    swiftCode: 'ANZBAU3M',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'westpac',
    nameAr: 'بنك ويستباك (Westpac)',
    nameEn: 'Westpac Banking Corporation',
    shortName: 'Westpac',
    logoAsset: 'assets/icons/banks/westpac.png',
    website: 'https://westpac.com.au',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/westpac.png',
    swiftCode: 'WPACAU2S',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'dbs',
    nameAr: 'بنك دي بي إس السنغافوري (DBS)',
    nameEn: 'DBS Bank Singapore',
    shortName: 'DBS',
    logoAsset: 'assets/icons/banks/dbs.png',
    website: 'https://dbs.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/dbs.png',
    swiftCode: 'DBSSSGSG',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'ocbc',
    nameAr: 'بنك أو سي بي سي (OCBC)',
    nameEn: 'OCBC Bank Singapore',
    shortName: 'OCBC',
    logoAsset: 'assets/icons/banks/ocbc.png',
    website: 'https://ocbc.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ocbc.png',
    swiftCode: 'OCBCSGSG',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'uob',
    nameAr: 'بنك يو أو بي (UOB)',
    nameEn: 'United Overseas Bank',
    shortName: 'UOB',
    logoAsset: 'assets/icons/banks/uob.png',
    website: 'https://uob.com.sg',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/uob.png',
    swiftCode: 'UOVBSGSG',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'sbi',
    nameAr: 'بنك الدولة الهندي (SBI)',
    nameEn: 'State Bank of India',
    shortName: 'SBI',
    logoAsset: 'assets/icons/banks/sbi.png',
    website: 'https://sbi.co.in',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/sbi.png',
    swiftCode: 'SBININBB',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'hdfc',
    nameAr: 'بنك إتش دي إف سي (HDFC Bank)',
    nameEn: 'HDFC Bank (India)',
    shortName: 'HDFC',
    logoAsset: 'assets/icons/banks/hdfc.png',
    website: 'https://hdfcbank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/hdfc.png',
    swiftCode: 'HDFCINBB',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'icici',
    nameAr: 'بنك آي سي آي سي آي (ICICI)',
    nameEn: 'ICICI Bank (India)',
    shortName: 'ICICI',
    logoAsset: 'assets/icons/banks/icici.png',
    website: 'https://icicibank.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/icici.png',
    swiftCode: 'ICICINBB',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'boc',
    nameAr: 'بنك أوف تشاينا (Bank of China)',
    nameEn: 'Bank of China',
    shortName: 'BOC',
    logoAsset: 'assets/icons/banks/boc.png',
    website: 'https://boc.cn',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/boc.png',
    swiftCode: 'BKCHCNBJ',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'icbc',
    nameAr: 'البنك الصناعي والتجاري الصيني (ICBC)',
    nameEn: 'Industrial and Commercial Bank of China',
    shortName: 'ICBC',
    logoAsset: 'assets/icons/banks/icbc.png',
    website: 'https://icbc.com.cn',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/icbc.png',
    swiftCode: 'ICBCCNBS',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'smbc',
    nameAr: 'سوميتومو ميتسوي المصرفية (SMBC)',
    nameEn: 'Sumitomo Mitsui Banking',
    shortName: 'SMBC',
    logoAsset: 'assets/icons/banks/smbc.png',
    website: 'https://smbc.co.jp',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/smbc.png',
    swiftCode: 'SMBCJPJT',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'mizuho',
    nameAr: 'بنك ميزوهو الياباني (Mizuho)',
    nameEn: 'Mizuho Bank',
    shortName: 'Mizuho',
    logoAsset: 'assets/icons/banks/mizuho.png',
    website: 'https://mizuhobank.co.jp',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/mizuho.png',
    swiftCode: 'MHCBJPJT',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'nubank',
    nameAr: 'نو بنك الرقمي (Nubank)',
    nameEn: 'Nubank (Latin America)',
    shortName: 'Nubank',
    logoAsset: 'assets/icons/banks/nubank.png',
    website: 'https://nubank.com.br',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nubank.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'itau',
    nameAr: 'بنك إيتاو البرازيلي (Itaú)',
    nameEn: 'Itaú Unibanco',
    shortName: 'Itaú',
    logoAsset: 'assets/icons/banks/itau.png',
    website: 'https://itau.com.br',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/itau.png',
    swiftCode: 'ITAUBRSP',
    isPopular: false,
    category: BankCategory.international,
  ),
  EgyptianBank(
    id: 'cashapp',
    nameAr: 'كاش آب (Cash App)',
    nameEn: 'Cash App',
    shortName: 'Cash App',
    logoAsset: 'assets/icons/banks/cashapp.png',
    website: 'https://cash.app',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/cashapp.png',
    swiftCode: null,
    isPopular: true,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'venmo',
    nameAr: 'فينمو (Venmo)',
    nameEn: 'Venmo by PayPal',
    shortName: 'Venmo',
    logoAsset: 'assets/icons/banks/venmo.png',
    website: 'https://venmo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/venmo.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'robinhood',
    nameAr: 'روبن هود (Robinhood)',
    nameEn: 'Robinhood',
    shortName: 'Robinhood',
    logoAsset: 'assets/icons/banks/robinhood.png',
    website: 'https://robinhood.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/robinhood.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'brex',
    nameAr: 'بريكس (Brex Card)',
    nameEn: 'Brex',
    shortName: 'Brex',
    logoAsset: 'assets/icons/banks/brex.png',
    website: 'https://brex.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/brex.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'ramp',
    nameAr: 'رامب (Ramp Card)',
    nameEn: 'Ramp',
    shortName: 'Ramp',
    logoAsset: 'assets/icons/banks/ramp.png',
    website: 'https://ramp.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/ramp.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'stripe',
    nameAr: 'سترايب (Stripe Treasury)',
    nameEn: 'Stripe Issuing & Treasury',
    shortName: 'Stripe',
    logoAsset: 'assets/icons/banks/stripe.png',
    website: 'https://stripe.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/stripe.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'curve',
    nameAr: 'كيرف (Curve)',
    nameEn: 'Curve',
    shortName: 'Curve',
    logoAsset: 'assets/icons/banks/curve.png',
    website: 'https://curve.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/curve.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'monese',
    nameAr: 'مونيز (Monese Bank)',
    nameEn: 'Monese',
    shortName: 'Monese',
    logoAsset: 'assets/icons/banks/monese.png',
    website: 'https://monese.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/monese.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'moneygram',
    nameAr: 'موني جرام (MoneyGram)',
    nameEn: 'MoneyGram',
    shortName: 'MoneyGram',
    logoAsset: 'assets/icons/banks/moneygram.png',
    website: 'https://moneygram.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/moneygram.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'neteller',
    nameAr: 'نتلر (Neteller Wallet)',
    nameEn: 'Neteller',
    shortName: 'Neteller',
    logoAsset: 'assets/icons/banks/neteller.png',
    website: 'https://neteller.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/neteller.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'coinbase',
    nameAr: 'كوين بيس (Coinbase Card)',
    nameEn: 'Coinbase',
    shortName: 'Coinbase',
    logoAsset: 'assets/icons/banks/coinbase.png',
    website: 'https://coinbase.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/coinbase.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'bybit',
    nameAr: 'باي بيت (Bybit Card)',
    nameEn: 'Bybit',
    shortName: 'Bybit',
    logoAsset: 'assets/icons/banks/bybit.png',
    website: 'https://bybit.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/bybit.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'okx',
    nameAr: 'أو كي إكس (OKX Card)',
    nameEn: 'OKX',
    shortName: 'OKX',
    logoAsset: 'assets/icons/banks/okx.png',
    website: 'https://okx.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/okx.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
  EgyptianBank(
    id: 'nexo',
    nameAr: 'نيكسو (Nexo Card)',
    nameEn: 'Nexo',
    shortName: 'Nexo',
    logoAsset: 'assets/icons/banks/nexo.png',
    website: 'https://nexo.com',
    logoUrl: 'https://mahfazati.runasp.net/images/banks/nexo.png',
    swiftCode: null,
    isPopular: false,
    category: BankCategory.fintech,
  ),
];

/// Full-page picker screen for all banks, neo-banks, and fintech apps.
class BankPickerScreen extends StatefulWidget {
  final String? initialBank;
  final bool autoSync;

  const BankPickerScreen({
    super.key,
    this.initialBank,
    this.autoSync = true,
  });

  /// Convenient helper to push this screen with native platform transitions.
  static Future<String?> open(
    BuildContext context, {
    String? initialBank,
    bool autoSync = true,
  }) {
    if (Platform.isIOS) {
      return Navigator.push<String>(
        context,
        CupertinoPageRoute(
          builder: (_) => BankPickerScreen(
            initialBank: initialBank,
            autoSync: autoSync,
          ),
        ),
      );
    } else {
      return Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => BankPickerScreen(
            initialBank: initialBank,
            autoSync: autoSync,
          ),
        ),
      );
    }
  }

  @override
  State<BankPickerScreen> createState() => _BankPickerScreenState();
}

class _BankPickerScreenState extends State<BankPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedCategory = 'all'; // 'all', 'popular', 'egyptian', 'fintech', 'international'
  late String? _selectedBankName;
  late List<EgyptianBank> _banks;

  @override
  void initState() {
    super.initState();
    _selectedBankName = widget.initialBank;
    _banks = BankRepository().cachedBanks;
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    if (!widget.autoSync) return;
    try {
      final remote = await BankRepository().getBanks();
      if (mounted && remote.isNotEmpty) {
        setState(() {
          _banks = remote;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onBankSelected(String bankName) {
    HapticFeedback.selectionClick();
    setState(() => _selectedBankName = bankName);
    Navigator.of(context).pop(bankName);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final secondaryTextColor =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final List<_BankSectionItem> sectionItems = [];

    if (_searchQuery.isNotEmpty) {
      final matching = _banks.where((b) => b.matches(_searchQuery)).toList();
      if (matching.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(
          isAr ? 'نتائج البحث' : 'Search Results',
          matching.length,
        ));
        for (final b in matching) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }
    } else if (_selectedCategory != 'all') {
      List<EgyptianBank> catBanks;
      String title;
      switch (_selectedCategory) {
        case 'popular':
          catBanks = _banks.where((b) => b.isPopular).toList();
          title = isAr ? 'الأكثر استخداماً' : 'Most Popular';
          break;
        case 'egyptian':
          catBanks = _banks
              .where((b) => b.category == BankCategory.egyptian)
              .toList();
          title = isAr ? 'البنوك المصرية' : 'Egyptian Banks';
          break;
        case 'fintech':
          catBanks = _banks
              .where((b) => b.category == BankCategory.fintech)
              .toList();
          title = isAr ? 'تطبيقات ومحافظ رقمية' : 'Fintech & Digital Wallets';
          break;
        case 'international':
        default:
          catBanks = _banks
              .where((b) => b.category == BankCategory.international)
              .toList();
          title = isAr ? 'بنوك حول العالم' : 'Banks Around the World';
          break;
      }
      if (catBanks.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(title, catBanks.length));
        for (final b in catBanks) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }
    } else {
      // Grouped by 4 primary sections:
      final popular = _banks.where((b) => b.isPopular).toList();
      final egyptian = _banks
          .where((b) => b.category == BankCategory.egyptian && !b.isPopular)
          .toList();
      final fintech = _banks
          .where((b) => b.category == BankCategory.fintech && !b.isPopular)
          .toList();
      final international = _banks
          .where((b) => b.category == BankCategory.international && !b.isPopular)
          .toList();

      if (popular.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(
          isAr ? 'الأكثر استخداماً' : 'Most Popular',
          popular.length,
        ));
        for (final b in popular) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }

      if (egyptian.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(
          isAr ? 'البنوك المحلية' : 'Local Egyptian Banks',
          egyptian.length,
        ));
        for (final b in egyptian) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }

      if (fintech.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(
          isAr ? 'تطبيقات ومحافظ رقمية' : 'Fintech & Digital Wallets',
          fintech.length,
        ));
        for (final b in fintech) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }

      if (international.isNotEmpty) {
        sectionItems.add(_BankSectionItem.header(
          isAr ? 'بنوك حول العالم' : 'Banks Around the World',
          international.length,
        ));
        for (final b in international) {
          sectionItems.add(_BankSectionItem.bank(b));
        }
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: Text(
          isAr ? 'اختيار البنك أو التطبيق' : 'Select Bank or App',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: primaryTextColor,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 4),

            // Search Bar (identical to CurrencyPickerScreen)
            _buildSearchBar(isDarkMode, isAr, cardBg, borderColor, secondaryTextColor),

            const SizedBox(height: 10),

            // Category Filter Chips
            if (_searchQuery.isEmpty) ...[
              _buildCategoryChips(isDarkMode, isAr, primaryTextColor, secondaryTextColor),
              const SizedBox(height: 8),
            ],

            // Unified Smooth Banks List
            Expanded(
              child: sectionItems.isEmpty
                  ? _buildEmptyState(isDarkMode, isAr, primaryTextColor, secondaryTextColor)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        2,
                        16,
                        safeAreaBottom > 0 ? safeAreaBottom + 40 : 50,
                      ),
                      itemCount: sectionItems.length,
                      itemBuilder: (context, index) {
                        final item = sectionItems[index];

                        if (item.isHeader) {
                          return _buildSectionHeader(
                            item.headerTitle!,
                            item.headerCount!,
                            isDarkMode,
                            primaryTextColor,
                            secondaryTextColor,
                          );
                        }

                        final bank = item.bank!;
                        final isSelected = _isBankSelected(bank);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildBankTile(
                            bank: bank,
                            isSelected: isSelected,
                            isDarkMode: isDarkMode,
                            isAr: isAr,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isBankSelected(EgyptianBank b) {
    if (_selectedBankName == null) return false;
    final selected = _selectedBankName!.trim().toLowerCase();
    return selected == b.nameAr.toLowerCase() ||
        selected == b.nameEn.toLowerCase() ||
        selected == b.cleanName(true).toLowerCase() ||
        selected == b.cleanName(false).toLowerCase() ||
        selected == b.shortName.toLowerCase();
  }

  // ==========================================
  // SEARCH BAR (Matching CurrencyPickerScreen)
  // ==========================================
  Widget _buildCategoryChips(
    bool isDarkMode,
    bool isAr,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final categories = [
      {
        'id': 'all',
        'label': isAr ? 'الكل' : 'All',
        'icon': Icons.apps_rounded,
      },
      {
        'id': 'popular',
        'label': isAr ? 'الأكثر طلباً' : 'Popular',
        'icon': Icons.star_rounded,
      },
      {
        'id': 'egyptian',
        'label': isAr ? 'بنوك مصر' : 'Local Banks',
        'icon': Icons.account_balance_rounded,
      },
      {
        'id': 'fintech',
        'label': isAr ? 'محافظ وتطبيقات' : 'Fintech',
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'id': 'international',
        'label': isAr ? 'بنوك العالم' : 'World Banks',
        'icon': Icons.public_rounded,
      },
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['id'];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat['id'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05)),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 14.5,
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : secondaryTextColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDarkMode ? Colors.black : Colors.white)
                            : secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    bool isDarkMode,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: primaryTextColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    bool isDarkMode,
    bool isAr,
    Color cardBg,
    Color borderColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          cursorColor: isDarkMode ? Colors.white : Colors.black,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: secondaryTextColor,
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: secondaryTextColor,
                    ),
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 40),
            hintText: isAr
                ? 'ابحث باسم البنك أو التطبيق...'
                : 'Search by bank or app name...',
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
            ),
          ),
          onChanged: (val) {
            setState(() => _searchQuery = val.trim());
          },
        ),
      ),
    );
  }

  Widget _buildBankTile({
    required EgyptianBank bank,
    required bool isSelected,
    required bool isDarkMode,
    required bool isAr,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF007AFF)
              : borderColor,
          width: isSelected ? 1.6 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onBankSelected(bank.cleanName(isAr)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Bank Logo Avatar
                _buildBankAvatar(bank, isDarkMode, primaryTextColor),
                const SizedBox(width: 14),

                // Bank Name (Clean, single line, NO description underneath)
                Expanded(
                  child: Text(
                    isAr ? bank.nameAr : bank.nameEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: primaryTextColor,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Selected Checkmark Badge
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    appForwardIconOf(context),
                    size: 20,
                    color: secondaryTextColor.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankAvatar(
    EgyptianBank bank,
    bool isDarkMode,
    Color primaryTextColor,
  ) {
    final netLogo = bank.effectiveLogoUrl;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.network(
            netLogo,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _buildInitialFallback(bank, primaryTextColor);
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildInitialFallback(bank, primaryTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialFallback(EgyptianBank bank, Color primaryTextColor) {
    final initial = bank.shortName.isNotEmpty
        ? (bank.shortName.length <= 4 ? bank.shortName : bank.shortName.substring(0, 3))
        : (bank.nameAr.isNotEmpty ? bank.nameAr.substring(0, 1) : '?');
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: initial.length <= 2 ? 14 : 12,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDarkMode,
    bool isAr,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 48,
              color: secondaryTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              isAr
                  ? 'لا توجد نتائج لـ "$_searchQuery"'
                  : 'No results for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'جرب البحث باسم البنك أو التطبيق بالعربي أو بالإنجليزي'
                  : 'Try searching with bank or app name in Arabic or English',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Text(
                isAr ? 'مسح البحث' : 'Clear search',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankSectionItem {
  final String? headerTitle;
  final int? headerCount;
  final EgyptianBank? bank;

  _BankSectionItem.header(this.headerTitle, this.headerCount) : bank = null;
  _BankSectionItem.bank(this.bank)
      : headerTitle = null,
        headerCount = null;

  bool get isHeader => headerTitle != null;
}
