import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final amharicGlossaryProvider = Provider<Map<String, String>>((ref) => const {
  'jaundice': 'አረዳ',
  'shortness of breath': 'የመረታ መቅደም',
  'difficulty breathing': 'የመረታ አናጋሪ',
  'headache': 'የጭነት ማዕከል',
  'fever': 'ፋይበር',
  'cough': 'ክᕐሳ',
  'chest pain': 'የመተላለፊያ ሳድም',
  'abdominal pain': 'የደብተው ሳድም',
  'nausea': 'የበሽታ ጥሩብ',
  'vomiting': 'ዕቃዕቃ',
  'diarrhea': 'ድርጀት',
  'constipation': 'የደብተው የመተላለፊያ',
  'dizziness': 'የበሽታ ጭንቆላ',
  'fatigue': 'የበሽታ ወጥዎች',
  'weakness': 'በሽታ',
  'chills': 'የበሽታ ንፁህ በሽታ',
  'rash': 'ዕጣ',
  'swelling': 'እፅዋት',
  'bleeding': 'የደም ጣፋጭ',
  'pain': 'ሳድም',
  'hypertension': 'የደም ጤኅል ብርቱ',
  'hypotension': 'የደም ጤኅል ዘብዕይ',
  'tachycardia': 'የደም ጤኅል በስላሳዊት',
  'bradycardia': 'የደም ጤኅል በበታቃዊ',
  'palpitation': 'የደም ጤኅል ማስታወሻ',
  'dyspnea': 'የመረታ መቅደም የሌሊት',
  'orthopnea': 'የመረታ መቅደም ከ� stand',
  'edema': 'እፅዋት',
  'anemia': 'የደም ቤት የሌሊት',
  'infection': 'በሽታ',
  'inflammation': 'እብስብ',
  'sepsis': 'የበሽታ እብስብ',
  'shock': 'አሽከር',
  'stroke': 'ደም በስላዊት',
  'heart attack': 'የደም ጤኅል አጠፋ',
  'heart failure': 'የደም ጤኅል የማዕከል',
  'diabetes': 'የሐብር የበሽታ',
  'asthma': 'የመታወቂያ አገልግሎት',
  'copd': 'የመታወቂያ አገልግሎት ዘብዕይ',
  'pneumonia': 'የመታወቂያ ቤት አጠፋ',
  'bronchitis': 'የመታወቂያ አገልግሎት የተለያዩ',
  'arthritis': 'የገነት ቤት የተለያዩ',
  'fracture': 'የገነት ተሞልቶ',
  'ulcer': 'የገነት ተሞልቶ',
  'cancer': 'ሲንክ',
  'tumor': 'ክብ',
  'virus': 'ዛዛዲ',
  'bacteria': 'በርታርሲክ',
  'antibiotic': 'አንቴቲብዪቲክ',
  'medication': 'መድብህ',
  'prescription': 'የመድብህ መመርመሪያ',
  'laboratory': 'ላብነር',
  'x-ray': 'ኤክስ-ራይ',
  'mri': 'ኤም-አር-አይ',
  'ct scan': 'ሲ-ቲ ስኬን',
  'ultrasound': 'አልትራዳዲር',
  'blood test': 'ደሞ ሞያ',
  'urine test': 'የዚያ ሞያ',
  'ecg': 'አይ-ሲ-ጂ',
  'ekg': 'አይ-ኬክ-ጂ',
  'biopsy': 'ባዮፕሲ',
  'surgery': 'ቀንድ',
  'operation': 'ማዕከል',
  'emergency': 'የአደጋ',
  'urgent': 'የአብላእ',
});

class AmharicTapText extends ConsumerWidget {
  const AmharicTapText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glossary = ref.watch(amharicGlossaryProvider);
    final theme = Theme.of(context);

    return _TappableText(
      text: text,
      glossary: glossary,
      style: TextStyle(color: theme.colorScheme.onSurface, height: 1.5),
    );
  }
}

class _TappableText extends StatefulWidget {
  const _TappableText({
    required this.text,
    required this.glossary,
    required this.style,
  });

  final String text;
  final Map<String, String> glossary;
  final TextStyle style;

  @override
  State<_TappableText> createState() => _TappableTextState();
}

class _TappableTextState extends State<_TappableText> {
  List<_Match> _findMatches(String text, Map<String, String> glossary) {
    final matches = <_Match>[];
    for (final entry in glossary.entries) {
      final term = entry.key;
      var idx = 0;
      while (idx < text.length) {
        final found = text.toLowerCase().indexOf(term.toLowerCase(), idx);
        if (found == -1) break;
        matches.add(_Match(
          start: found,
          end: found + term.length,
          term: text.substring(found, found + term.length),
          translation: entry.value,
        ));
        idx = found + 1;
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final matches = _findMatches(widget.text, widget.glossary);

    if (matches.isEmpty) {
      return SelectableText(
        widget.text,
        style: widget.style,
      );
    }

    final children = <TextSpan>[];
    var lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        children.add(TextSpan(text: widget.text.substring(lastEnd, match.start)));
      }
      children.add(TextSpan(
        text: match.term,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${match.term} → ${match.translation}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
      ));
      lastEnd = match.end;
    }

    if (lastEnd < widget.text.length) {
      children.add(TextSpan(text: widget.text.substring(lastEnd)));
    }

    return SelectableText.rich(
      TextSpan(children: children, style: widget.style),
    );
  }
}

class _Match {
  _Match({required this.start, required this.end, required this.term, required this.translation});
  final int start;
  final int end;
  final String term;
  final String translation;
}