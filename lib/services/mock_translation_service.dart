import '../models/translation_result.dart';
import 'translation_service.dart';

/// Real working mock translation service for BhashaSetu prototype demonstrations.
/// Uses a curated, clearly labelled sample dictionary of primary classroom phrases
/// and vocabulary between Hindi and Santhali (Devanagari, Ol Chiki, and phonetic).
class MockTranslationService implements TranslationService {
  final Duration simulatedDelay;

  const MockTranslationService({
    this.simulatedDelay = const Duration(milliseconds: 250),
  });

  @override
  bool get isDemo => true;

  // Normalized key -> (Translated text, phonetic guide)
  static final Map<String, (String, String?)> _hindiToSanthali = {
    // Classroom Greetings & Instructions
    'नमस्ते': ('ᱡᱚᱦᱟᱨ', 'Johar'),
    'जोहार': ('ᱡᱚᱦᱟᱨ', 'Johar'),
    'नमस्कार': ('ᱡᱚᱦᱟᱨ', 'Johar'),
    'आप कैसे हैं': ('ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ?', 'Ched leka menama?'),
    'आप कैसे हो': ('ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ?', 'Ched leka menama?'),
    'तुम कैसे हो': ('ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ?', 'Ched leka menama?'),
    'किताब खोलो': ('ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ', 'Puthi jhij me'),
    'अपनी किताब खोलो': ('ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ', 'Amag puthi jhij me'),
    'किताब बंद करो': ('ᱯᱩᱛᱷᱤ ᱵᱚᱸᱫᱽ ᱢᱮ', 'Puthi bond me'),
    'ध्यान से सुनो': ('ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ', 'Dheyan te anjom me'),
    'सुनो': ('ᱟᱧᱡᱚᱢ ᱢᱮ', 'Anjom me'),
    'मेरे बाद दोहराओ': ('ᱤᱧ ᱛᱟᱭᱚᱢ ᱛᱮ ᱢᱮᱱ ᱢᱮ', 'Inj tayom te men me'),
    'दोहराओ': ('ᱫᱚᱦᱲᱟᱭ ᱢᱮ', 'Dohray me'),
    'क्या आप समझ गए': ('ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟᱢ?', 'Bujhau kedam?'),
    'समझ गए': ('ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟᱢ?', 'Bujhau kedam?'),
    'समझ में आया': ('ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟᱢ?', 'Bujhau kedam?'),
    'अपना गृहकार्य पूरा करो': ('ᱟᱢᱟᱜ ᱚᱲᱟᱜ ᱠᱟᱹᱢᱤ ᱯᱩᱨᱟᱹᱣ ᱢᱮ', 'Amag orag kami puraw me'),
    'गृहकार्य पूरा करो': ('ᱚᱲᱟᱜ ᱠᱟᱹᱢᱤ ᱯᱩᱨᱟᱹᱣ ᱢᱮ', 'Orag kami puraw me'),
    'होमवर्क पूरा करो': ('ᱚᱲᱟᱜ ᱠᱟᱹᱢᱤ ᱯᱩᱨᱟᱹᱣ ᱢᱮ', 'Orag kami puraw me'),
    'बहुत अच्छा': ('ᱟᱹᱰᱤ ᱵᱷᱟᱹᱜᱤ', 'Adi bhagi'),
    'शाबाश': ('ᱟᱹᱰᱤ ᱵᱷᱟᱹᱜᱤ', 'Adi bhagi'),
    'बैठ जाओ': ('ᱫᱩᱲᱩᱵ ᱢᱮ', 'Durub me'),
    'बैठो': ('ᱫᱩᱲᱩᱵ ᱢᱮ', 'Durub me'),
    'खड़े हो जाओ': ('ᱛᱤᱸᱜᱩᱱ ᱢᱮ', 'Tingun me'),
    'खड़े रहो': ('ᱛᱤᱸᱜᱩᱱ ᱢᱮ', 'Tingun me'),
    'धन्यवाद': ('ᱥᱟᱨᱦᱟᱣ', 'Sarhaw'),
    'यहाँ आओ': ('ᱱᱚᱸᱰᱮ ᱦᱤᱡᱩᱜ ᱢᱮ', 'Nonde hijug me'),
    'वहाँ जाओ': ('ᱦᱟᱸᱰᱮ ᱥᱮᱱᱚᱜ ᱢᱮ', 'Hande senog me'),
    'लिखो': ('ᱚᱞ ᱢᱮ', 'Ol me'),
    'पढ़ो': ('ᱯᱟᱲᱦᱟᱣ ᱢᱮ', 'Parhaw me'),
    'पढ़ो': ('ᱯᱟᱲᱦᱟᱣ ᱢᱮ', 'Parhaw me'),

    // Everyday Words
    'पानी': ('ᱫᱟᱜ', 'Dak'),
    'जल': ('ᱫᱟᱜ', 'Dak'),
    'स्कूल': ('ᱤᱛᱩᱱ ᱟᱥᱲᱟ', 'Itun Asra'),
    'विद्यालय': ('ᱤᱛᱩᱱ ᱟᱥᱲᱟ', 'Itun Asra'),
    'किताब': ('ᱯᱩᱛᱷᱤ', 'Puthi'),
    'पुस्तक': ('ᱯᱩᱛᱷᱤ', 'Puthi'),
    'कलम': ('ᱠᱚᱞᱚᱢ', 'Kalom'),
    'घर': ('ᱚᱲᱟᱜ', 'Orak'),
    'पेड़': ('ᱫᱟᱨᱮ', 'Dare'),
    'फूल': ('ᱵᱟᱦᱟ', 'Baha'),
    'सूरज': ('ᱥᱤᱸᱜᱤ', 'Singi'),
    'चाँद': ('ᱪᱟᱸᱫᱚ', 'Chando'),
    'चांद': ('ᱪᱟᱸᱫᱚ', 'Chando'),
    'खाना': ('ᱫᱟᱠᱟ', 'Daka'),
    'रोटी': ('ᱨᱩᱴᱤ', 'Ruti'),
    'दूध': ('ᱛᱳᱣᱟ', 'Towa'),
    'लड़का': ('ᱠᱚᱲᱟ', 'Kora'),
    'लड़की': ('ᱠᱩᱲᱤ', 'Kuri'),
    'शिक्षक': ('ᱢᱟᱪᱮᱛ', 'Machet'),
    'गुरुजी': ('ᱢᱟᱪᱮᱛ', 'Machet'),
    'छात्र': ('ᱪᱮᱪᱮᱫᱤᱭᱟᱹ', 'Chechediya'),
  };

  static final Map<String, (String, String?)> _santhaliToHindi = {
    // Ol Chiki script inputs
    'ᱡᱚᱦᱟᱨ': ('नमस्ते', 'Namaste'),
    'ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ': ('आप कैसे हैं?', 'Aap kaise hain?'),
    'ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ': ('किताब खोलो', 'Kitab kholo'),
    'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ': ('अपनी किताब खोलो', 'Apni kitab kholo'),
    'ᱯᱩᱛᱷᱤ ᱵᱚᱸᱫᱽ ᱢᱮ': ('किताब बंद करो', 'Kitab band karo'),
    'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ': ('ध्यान से सुनो', 'Dhyan se suno'),
    'ᱟᱧᱡᱚᱢ ᱢᱮ': ('सुनो', 'Suno'),
    'ᱤᱧ ᱛᱟᱭᱚᱢ ᱛᱮ ᱢᱮᱱ ᱢᱮ': ('मेरे बाद दोहराओ', 'Mere baad dohrao'),
    'ᱫᱚᱦᱲᱟᱭ ᱢᱮ': ('दोहराओ', 'Dohrao'),
    'ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟᱢ': ('क्या आप समझ गए?', 'Kya aap samajh gaye?'),
    'ᱟᱢᱟᱜ ᱚᱲᱟᱜ ᱠᱟᱹᱢᱤ ᱯᱩᱨᱟᱹᱣ ᱢᱮ': ('अपना गृहकार्य पूरा करो', 'Apna grihkarya poora karo'),
    'ᱚᱲᱟᱜ ᱠᱟᱹᱢᱤ ᱯᱩᱨᱟᱹᱣ ᱢᱮ': ('गृहकार्य पूरा करो', 'Grihkarya poora karo'),
    'ᱟᱹᱰᱤ ᱵᱷᱟᱹᱜᱤ': ('बहुत अच्छा!', 'Bahut achha!'),
    'ᱫᱩᱲᱩᱵ ᱢᱮ': ('बैठ जाओ', 'Baith jao'),
    'ᱛᱤᱸᱜᱩᱱ ᱢᱮ': ('खड़े हो जाओ', 'Khade ho jao'),
    'ᱥᱟᱨᱦᱟᱣ': ('धन्यवाद', 'Dhanyawad'),
    'ᱱᱚᱸᱰᱮ ᱦᱤᱡᱩᱜ ᱢᱮ': ('यहाँ आओ', 'Yahan aao'),
    'ᱦᱟᱸᱰᱮ ᱥᱮᱱᱚᱜ ᱢᱮ': ('वहाँ जाओ', 'Wahan jao'),
    'ᱚᱞ ᱢᱮ': ('लिखो', 'Likho'),
    'ᱯᱟᱲᱦᱟᱣ ᱢᱮ': ('पढ़ो', 'Padho'),

    'ᱫᱟᱜ': ('पानी', 'Paani'),
    'ᱤᱛᱩᱱ ᱟᱥᱲᱟ': ('स्कूल', 'School'),
    'ᱯᱩᱛᱷᱤ': ('किताब', 'Kitab'),
    'ᱠᱚᱞᱚᱢ': ('कलम', 'Kalam'),
    'ᱚᱲᱟᱜ': ('घर', 'Ghar'),
    'ᱫᱟᱨᱮ': ('पेड़', 'Ped'),
    'ᱵᱟᱦᱟ': ('फूल', 'Phool'),
    'ᱥᱤᱸᱜᱤ': ('सूरज', 'Suraj'),
    'ᱪᱟᱸᱫᱚ': ('चाँद', 'Chand'),
    'ᱫᱟᱠᱟ': ('खाना / भात', 'Khana / Bhaat'),
    'ᱨᱩᱴᱤ': ('रोटी', 'Roti'),
    'ᱛᱳᱣᱟ': ('दूध', 'Doodh'),
    'ᱠᱚᱲᱟ': ('लड़का', 'Ladka'),
    'ᱠᱩᱲᱤ': ('लड़की', 'Ladki'),
    'ᱢᱟᱪᱮᱛ': ('शिक्षक / गुरुजी', 'Shikshak / Guruji'),
    'ᱪᱮᱪᱮᱫᱤᱭᱟᱹ': ('छात्र / विद्यार्थी', 'Chhatra / Vidyarthi'),

    // Romanized / phonetic variants for flexible demo typing
    'johar': ('नमस्ते', 'Namaste'),
    'ched leka menama': ('आप कैसे हैं?', 'Aap kaise hain?'),
    'puthi jhij me': ('किताब खोलो', 'Kitab kholo'),
    'dheyan te anjom me': ('ध्यान से सुनो', 'Dhyan se suno'),
    'inj tayom te men me': ('मेरे बाद दोहराओ', 'Mere baad dohrao'),
    'bujhau kedam': ('क्या आप समझ गए?', 'Kya aap samajh gaye?'),
    'orag kami puraw me': ('गृहकार्य पूरा करो', 'Grihkarya poora karo'),
    'adi bhagi': ('बहुत अच्छा!', 'Bahut achha!'),
    'durub me': ('बैठ जाओ', 'Baith jao'),
    'tingun me': ('खड़े हो जाओ', 'Khade ho jao'),
    'sarhaw': ('धन्यवाद', 'Dhanyawad'),
    'dak': ('पानी', 'Paani'),
    'itun asra': ('स्कूल', 'School'),
    'puthi': ('किताब', 'Kitab'),
    'kalom': ('कलम', 'Kalam'),
    'orak': ('घर', 'Ghar'),
    'dare': ('पेड़', 'Ped'),
    'baha': ('फूल', 'Phool'),
    'singi': ('सूरज', 'Suraj'),
    'chando': ('चाँद', 'Chand'),
    'machet': ('शिक्षक', 'Shikshak'),
  };

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s]+'), ' ')
        .replaceAll(RegExp(r'[।!?,.;:?؟]+$'), '')
        .trim();
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      throw const TranslationException('Please enter text to translate.');
    }

    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final key = _normalize(cleaned);
    final isSourceHindi = sourceLang.toLowerCase().contains('hindi');

    final dictionary = isSourceHindi ? _hindiToSanthali : _santhaliToHindi;

    final match = dictionary[key];
    if (match != null) {
      return TranslationResult(
        sourceText: cleaned,
        translatedText: match.$1,
        sourceLang: sourceLang,
        targetLang: targetLang,
        isDemo: true,
        badge: 'Demo Translation',
        timestamp: DateTime.now(),
        phoneticGuide: match.$2,
      );
    }

    // Try substring or word boundary match if available
    for (final entry in dictionary.entries) {
      if (entry.key == key || key.contains(entry.key) || entry.key.contains(key)) {
        return TranslationResult(
          sourceText: cleaned,
          translatedText: entry.value.$1,
          sourceLang: sourceLang,
          targetLang: targetLang,
          isDemo: true,
          badge: 'Demo Translation',
          timestamp: DateTime.now(),
          phoneticGuide: entry.value.$2,
        );
      }
    }

    // Honest handling of unsupported phrases — do NOT invent fake translations
    throw const TranslationException(
      'Demo translation is not available for this phrase yet.',
    );
  }
}
