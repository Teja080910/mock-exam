import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';

bool? addtoFavotire(
  List<QuizModelStruct> quizList,
  QuizModelStruct? quizData,
) {
  if (quizList.contains(quizData)) {
    return false;
  } else {
    return true;
  }
}

String getCountryISOByPhoneCode(String code) {
  Map<String, String> countryPhoneCodes = {
    "93": "AF", // Afghanistan
    "355": "AL", // Albania
    "213": "DZ", // Algeria
    "376": "AD", // Andorra
    "244": "AO", // Angola
    "54": "AR", // Argentina
    "374": "AM", // Armenia
    "61": "AU", // Australia
    "43": "AT", // Austria
    "994": "AZ", // Azerbaijan
    "973": "BH", // Bahrain
    "880": "BD", // Bangladesh
    "375": "BY", // Belarus
    "32": "BE", // Belgium
    "501": "BZ", // Belize
    "229": "BJ", // Benin
    "975": "BT", // Bhutan
    "591": "BO", // Bolivia
    "387": "BA", // Bosnia and Herzegovina
    "267": "BW", // Botswana
    "55": "BR", // Brazil
    "673": "BN", // Brunei
    "359": "BG", // Bulgaria
    "226": "BF", // Burkina Faso
    "257": "BI", // Burundi
    "855": "KH", // Cambodia
    "237": "CM", // Cameroon
    "1": "CA", // Canada
    "238": "CV", // Cape Verde
    "236": "CF", // Central African Republic
    "235": "TD", // Chad
    "56": "CL", // Chile
    "86": "CN", // China
    "57": "CO", // Colombia
    "269": "KM", // Comoros
    "243": "CD", // Democratic Republic of the Congo
    "242": "CG", // Republic of the Congo
    "682": "CK", // Cook Islands
    "506": "CR", // Costa Rica
    "225": "CI", // Côte d'Ivoire
    "385": "HR", // Croatia
    "53": "CU", // Cuba
    "357": "CY", // Cyprus
    "420": "CZ", // Czech Republic
    "45": "DK", // Denmark
    "253": "DJ", // Djibouti
    "1": "DM", // Dominica
    "1": "DO", // Dominican Republic
    "593": "EC", // Ecuador
    "20": "EG", // Egypt
    "503": "SV", // El Salvador
    "240": "GQ", // Equatorial Guinea
    "291": "ER", // Eritrea
    "372": "EE", // Estonia
    "251": "ET", // Ethiopia
    "679": "FJ", // Fiji
    "358": "FI", // Finland
    "33": "FR", // France
    "241": "GA", // Gabon
    "220": "GM", // Gambia
    "995": "GE", // Georgia
    "49": "DE", // Germany
    "233": "GH", // Ghana
    "30": "GR", // Greece
    "299": "GL", // Greenland
    "502": "GT", // Guatemala
    "224": "GN", // Guinea
    "245": "GW", // Guinea-Bissau
    "592": "GY", // Guyana
    "509": "HT", // Haiti
    "504": "HN", // Honduras
    "852": "HK", // Hong Kong
    "36": "HU", // Hungary
    "354": "IS", // Iceland
    "91": "IN", // India
    "62": "ID", // Indonesia
    "98": "IR", // Iran
    "964": "IQ", // Iraq
    "353": "IE", // Ireland
    "972": "IL", // Israel
    "39": "IT", // Italy
    "1": "JM", // Jamaica
    "81": "JP", // Japan
    "962": "JO", // Jordan
    "7": "KZ", // Kazakhstan
    "254": "KE", // Kenya
    "686": "KI", // Kiribati
    "965": "KW", // Kuwait
    "996": "KG", // Kyrgyzstan
    "856": "LA", // Laos
    "371": "LV", // Latvia
    "961": "LB", // Lebanon
    "266": "LS", // Lesotho
    "231": "LR", // Liberia
    "218": "LY", // Libya
    "423": "LI", // Liechtenstein
    "370": "LT", // Lithuania
    "352": "LU", // Luxembourg
    "853": "MO", // Macau
    "389": "MK", // North Macedonia
    "261": "MG", // Madagascar
    "265": "MW", // Malawi
    "60": "MY", // Malaysia
    "960": "MV", // Maldives
    "223": "ML", // Mali
    "356": "MT", // Malta
    "692": "MH", // Marshall Islands
    "222": "MR", // Mauritania
    "230": "MU", // Mauritius
    "52": "MX", // Mexico
    "691": "FM", // Micronesia
    "373": "MD", // Moldova
    "377": "MC", // Monaco
    "976": "MN", // Mongolia
    "382": "ME", // Montenegro
    "212": "MA", // Morocco
    "258": "MZ", // Mozambique
    "95": "MM", // Myanmar
    "264": "NA", // Namibia
    "674": "NR", // Nauru
    "977": "NP", // Nepal
    "31": "NL", // Netherlands
    "64": "NZ", // New Zealand
    "505": "NI", // Nicaragua
    "227": "NE", // Niger
    "234": "NG", // Nigeria
    "850": "KP", // North Korea
    "47": "NO", // Norway
    "968": "OM", // Oman
    "92": "PK", // Pakistan
    "680": "PW", // Palau
    "507": "PA", // Panama
    "675": "PG", // Papua New Guinea
    "595": "PY", // Paraguay
    "51": "PE", // Peru
    "63": "PH", // Philippines
    "48": "PL", // Poland
    "351": "PT", // Portugal
    "974": "QA", // Qatar
    "40": "RO", // Romania
    "7": "RU", // Russia
    "250": "RW", // Rwanda
    "685": "WS", // Samoa
    "378": "SM", // San Marino
    "966": "SA", // Saudi Arabia
    "221": "SN", // Senegal
    "381": "RS", // Serbia
    "248": "SC", // Seychelles
    "232": "SL", // Sierra Leone
    "65": "SG", // Singapore
    "421": "SK", // Slovakia
    "386": "SI", // Slovenia
    "677": "SB", // Solomon Islands
    "252": "SO", // Somalia
    "27": "ZA", // South Africa
    "82": "KR", // South Korea
    "211": "SS", // South Sudan
    "34": "ES", // Spain
    "94": "LK", // Sri Lanka
    "249": "SD", // Sudan
    "597": "SR", // Suriname
    "268": "SZ", // Eswatini
    "46": "SE", // Sweden
    "41": "CH", // Switzerland
    "963": "SY", // Syria
    "886": "TW", // Taiwan
    "992": "TJ", // Tajikistan
    "255": "TZ", // Tanzania
    "66": "TH", // Thailand
    "670": "TL", // Timor-Leste
    "228": "TG", // Togo
    "676": "TO", // Tonga
    "216": "TN", // Tunisia
    "90": "TR", // Turkey
    "993": "TM", // Turkmenistan
    "688": "TV", // Tuvalu
    "256": "UG", // Uganda
    "380": "UA", // Ukraine
    "971": "AE", // United Arab Emirates
    "44": "GB", // United Kingdom
    "1": "US", // United States
    "598": "UY", // Uruguay
    "998": "UZ", // Uzbekistan
    "678": "VU", // Vanuatu
    "58": "VE", // Venezuela
    "84": "VN", // Vietnam
    "967": "YE", // Yemen
    "260": "ZM", // Zambia
    "263": "ZW", // Zimbabwe
  };
  return countryPhoneCodes[code] ?? "IN";
}

String timeConverter(String timeStamps) {
  DateTime parsedTime = DateTime.parse(timeStamps);
  final currentTime = DateTime.now();
  final difference = currentTime.difference(parsedTime);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else {
    return '${difference.inDays} days ago';
  }
}

String getCountryCodeInit(String phoneNumber) {
  Map<String, String> countryCodeMap = {
    '+93': 'AF', // افغانستان
    '+358': 'AX', // Åland
    '+355': 'AL', // Shqipëria
    '+213': 'DZ', // الجزائر
    '+1684': 'AS', // American Samoa
    '+376': 'AD', //  Andorra
    '+244': 'AO', // Angola
    '+1264': 'AI', // Anguilla
    '+672': 'AQ', // Antarctica
    '+1268': 'AG', // Antigua and Barbuda
    '+54': 'AR', // Argentina
    '+374': 'AM', // Հայաստան
    '+297': 'AW', // Aruba
    '+61': 'AU', // Australia
    '+43': 'AT', // Österreich
    '+994': 'AZ', // Azərbaycan
    '+1242': 'BS', // Bahamas
    '+973': 'BH', // البحرين
    '+880': 'BD', // বাংলাদেশ
    '+1246': 'BB', // Barbados
    '+375': 'BY', // Белару́сь
    '+32': 'BE', // België
    '+501': 'BZ', // Belize
    '+229': 'BJ', // Bénin
    '+1441': 'BM', // Bermuda
    '+975': 'BT', // འབྲུག་ཡུལ
    '+591': 'BO', // Bolivia
    '+387': 'BA', // Босна и Херцеговина
    '+267': 'BW', // Botswana
    '+47': 'BV', // Bouvetøya
    '+55': 'BR', // Brasil
    '+246': 'IO', // British Indian Ocean Territory
    '+1284': 'VG', // British Virgin Islands
    '+673': 'BN', // Brunei
    '+359': 'BG', // България
    '+226': 'BF', // Burkina Faso
    '+257': 'BI', // Burundi
    '+855': 'KH', // កម្ពុជា
    '+237': 'CM', // Cameroun
    '+1': 'CA', // Canada
    '+238': 'CV', // Cabo Verde
    '+1345': 'KY', // Cayman Islands
    '+236': 'CF', // République centrafricaine
    '+235': 'TD', // Tchad
    '+56': 'CL', // Chile
    '+86': 'CN', // 中国
    '+61': 'CX', // Christmas Island
    '+61': 'CC', // Cocos (Keeling) Islands
    '+57': 'CO', // Colombia
    '+269': 'KM', // Komori
    '+242': 'CG', // République du Congo
    '+243': 'CD', // République démocratique du Congo
    '+682': 'CK', // Cook Islands
    '+506': 'CR', // Costa Rica
    '+225': 'CI', // Côte d'Ivoire
    '+385': 'HR', // Hrvatska
    '+53': 'CU', // Cuba
    '+599': 'CW', // Curaçao
    '+357': 'CY', // Κύπρος
    '+420': 'CZ', // Česká republika
    '+45': 'DK', // Danmark
    '+253': 'DJ', // Djibouti
    '+1767': 'DM', // Dominica
    '+1': 'DO', // República Dominicana
    '+593': 'EC', // Ecuador
    '+20': 'EG', // مصر
    '+503': 'SV', // El Salvador
    '+240': 'GQ', // Guinea Ecuatorial
    '+291': 'ER', // إرتريا
    '+372': 'EE', // Eesti
    '+251': 'ET', // ኢትዮጵያ
    '+500': 'FK', // Falkland Islands
    '+298': 'FO', // Føroyar
    '+679': 'FJ', // Fiji
    '+358': 'FI', // Suomi
    '+33': 'FR', // France
    '+594': 'GF', // Guyane française
    '+689': 'PF', // Polynésie française
    '+262': 'TF', // Terres australes françaises
    '+241': 'GA', // Gabon
    '+220': 'GM', // Gambia
    '+995': 'GE', // საქართველო
    '+49': 'DE', // Deutschland
    '+233': 'GH', // Ghana
    '+350': 'GI', // Gibraltar
    '+30': 'GR', // Ελλάδα
    '+299': 'GL', // Grønland
    '+1473': 'GD', // Grenada
    '+590': 'GP', // Guadeloupe
    '+1671': 'GU', // Guam
    '+502': 'GT', // Guatemala
    '+44': 'GG', // Guernsey
    '+224': 'GN', // Guinée
    '+245': 'GW', // Guiné-Bissau
    '+592': 'GY', // Guyana
    '+509': 'HT', // Haïti
    '+672': 'HM', // Heard Island and McDonald Islands
    '+504': 'HN', // Honduras
    '+852': 'HK', // 香港
    '+379': 'VA', // Vaticano
    '+36': 'HU', // Magyarország
    '+354': 'IS', // Ísland
    '+91': 'IN', // भारत
    '+62': 'ID', // Indonesia
    '+98': 'IR', // ایران
    '+964': 'IQ', // العراق
    '+353': 'IE', // Éire
    '+44': 'IM', // Isle of
    '+972': 'IL', // ישראל
    '+39': 'IT', // Italia
    '+1876': 'JM', // Jamaica
    '+81': 'JP', // 日本
    '+44': 'JE', // Jersey
    '+962': 'JO', // الأردن
    '+7': 'KZ', // Қазақстан
    '+254': 'KE', // Kenya
    '+686': 'KI', // Kiribati
    '+850': 'KP', // 북한
    '+82': 'KR', // 대한민국
    '+383': 'XK', // Republika e Kosovës
    '+965': 'KW', // الكويت
    '+996': 'KG', // Кыргызстан
    '+856': 'LA', // ລາວ
    '+371': 'LV', // Latvija
    '+961': 'LB', // لبنان
    '+266': 'LS', // Lesotho
    '+231': 'LR', // Liberia
    '+218': 'LY', // ليبيا
    '+423': 'LI', // Liechtenstein
    '+370': 'LT', // Lietuva
    '+352': 'LU', // Luxembourg
    '+853': 'MO', // 澳門
    '+389': 'MK', // Македонија
    '+261': 'MG', // Madagascar
    '+265': 'MW', // Malawi
    '+60': 'MY', // Malaysia
    '+960': 'MV', // Maldives
    '+223': 'ML', // Mali
    '+356': 'MT', // Malta
    '+692': 'MH', // Marshall Islands
    '+596': 'MQ', // Martinique
    '+222': 'MR', // موريتانيا
    '+230': 'MU', // Maurice
    '+262': 'YT', // Mayotte
    '+52': 'MX', // México
    '+691': 'FM', // Micronesia
    '+373': 'MD', // Moldova
    '+377': 'MC', // Monaco
    '+976': 'MN', // Монгол улс
    '+382': 'ME', // Crna Gora
    '+1664': 'MS', // Montserrat
    '+212': 'MA', // المغرب
    '+258': 'MZ', // Moçambique
    '+95': 'MM', // Myanma
    '+264': 'NA', // Namibia
    '+674': 'NR', // Nauru
    '+977': 'NP', // नेपाल
    '+31': 'NL', // Nederland
    '+599': 'AN', // Netherlands Antilles
    '+687': 'NC', // Nouvelle-Calédonie
    '+64': 'NZ', // New Zealand
    '+505': 'NI', // Nicaragua
    '+227': 'NE', // Niger
    '+234': 'NG', // Nigeria
    '+683': 'NU', // Niue
    '+672': 'NF', // Norfolk Island
    '+1670': 'MP', // Northern Mariana Islands
    '+47': 'NO', // Norge
    '+968': 'OM', // عمان
    '+92': 'PK', // پاکستان
    '+680': 'PW', // Palau
    '+970': 'PS', // فلسطين
    '+507': 'PA', // Panamá
    '+675': 'PG', // Papua New Guinea
    '+595': 'PY', // Paraguay
    '+51': 'PE', // Perú
    '+63': 'PH', // Pilipinas
    '+64': 'PN', // Pitcairn Islands
    '+48': 'PL', // Polska
    '+351': 'PT', // Portugal
    '+1939': 'PR', // Puerto Rico
    '+1787': 'PR', // Puerto Rico
    '+974': 'QA', // قطر
    '+262': 'RE', // La Réunion
    '+40': 'RO', // România
    '+7': 'RU', // Россия
    '+250': 'RW', // Rwanda
    '+262': 'RE', // La Réunion
    '+590': 'BL', // Saint-Barthélemy
    '+290': 'SH', // Saint Helena
    '+1869': 'KN', // Saint Kitts and Nevis
    '+1758': 'LC', // Saint Lucia
    '+590': 'MF', // Saint-Martin
    '+508': 'PM', // Saint-Pierre-et-Miquelon
    '+1784': 'VC', // Saint Vincent and the Grenadines
    '+685': 'WS', // Samoa
    '+378': 'SM', // San Marino
    '+239': 'ST', // São Tomé e Príncipe
    '+966': 'SA', // العربية السعودية
    '+221': 'SN', // Sénégal
    '+381': 'RS', // Србија
    '+248': 'SC', // Seychelles
    '+232': 'SL', // Sierra Leone
    '+65': 'SG', // Singapore
    '+1721': 'SX', // Sint Maarten
    '+421': 'SK', // Slovensko
    '+386': 'SI', // Slovenija
    '+677': 'SB', // Solomon Islands
    '+252': 'SO', // Soomaaliya
    '+27': 'ZA', // South Africa
    '+500': 'GS', // South Georgia
    '+211': 'SS', // South Sudan
    '+34': 'ES', // España
    '+94': 'LK', // ශ්‍රී ලංකාව
    '+249': 'SD', // السودان
    '+597': 'SR', // Suriname
    '+47': 'SJ', // Svalbard og Jan Mayen
    '+268': 'SZ', // Swaziland
    '+46': 'SE', // Sverige
    '+41': 'CH', // Schweiz
    '+963': 'SY', // سوريا
    '+886': 'TW', // 台灣
    '+992': 'TJ', // Тоҷикистон
    '+255': 'TZ', // Tanzania
    '+66': 'TH', // ไทย
    '+670': 'TL', // Timor-Leste
    '+228': 'TG', // Togo
    '+690': 'TK', // Tokelau
    '+676': 'TO', // Tonga
    '+1868': 'TT', // Trinidad and Tobago
    '+216': 'TN', // تونس
    '+90': 'TR', // Türkiye
    '+993': 'TM', // Türkmenistan
    '+1649': 'TC', // Turks and Caicos Islands
    '+688': 'TV', // Tuvalu
    '+256': 'UG', // Uganda
    '+380': 'UA', // Україна
    '+971': 'AE', // الإمارات العربية المتحدة
    '+44': 'GB', // United Kingdom
    '+1': 'US', // United States
    '+598': 'UY', // Uruguay
    '+998': 'UZ', // Oʻzbekiston
    '+678': 'VU', // Vanuatu
    '+58': 'VE', // Venezuela
    '+84': 'VN', // Việt Nam
    '+1284': 'VG', // British Virgin Islands
    '+1340': 'VI', // United States Virgin Islands
    '+681': 'WF', // Wallis et Futuna
    '+212': 'EH', // الصحراء الغربية
    '+967': 'YE', // اليمن
    '+260': 'ZM', // Zambia
    '+263': 'ZW', // Zimbabwe
  };

  // Extract the prefix from the phone number
  String prefix = phoneNumber.startsWith('+') ? phoneNumber.split(' ')[0] : '';

  // Look up the country code
  return countryCodeMap[prefix] ?? 'Unknown';
}

bool hasCategoryAccess(
  String planStatus,
  bool isSelectedAll,
  List<String>? allowedCategoryIds,
  String? currentCategoryId,
  String? currentGroupId,
) {
  if (planStatus != 'active') {
    return false;
  }
  if (isSelectedAll) {
    return true;
  }
  if (allowedCategoryIds == null) {
    return false;
  }
  if (currentCategoryId != null &&
      allowedCategoryIds.contains(currentCategoryId)) {
    return true;
  }
  if (currentGroupId != null && allowedCategoryIds.contains(currentGroupId)) {
    return true;
  }
  return false;
}
