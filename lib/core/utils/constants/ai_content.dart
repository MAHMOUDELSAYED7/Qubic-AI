import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiConstantsContent {
  const AiConstantsContent._();

  static List<Content> content = [
    Content.text(dotenv.env['TEXT_1_EN']!),
    Content.text(dotenv.env['TEXT_1_AR']!),
    Content.text(dotenv.env['TEXT_2_EN']!),
    Content.text(dotenv.env['TEXT_2_AR']!),
    Content.text(dotenv.env['TEXT_3_EN']!),
    Content.text(dotenv.env['TEXT_3_AR']!),
    Content.text(dotenv.env['TEXT_4_EN']!),
    Content.text(dotenv.env['TEXT_4_AR']!),
    Content.text(dotenv.env['TEXT_5_EN']!),
    Content.text(dotenv.env['TEXT_5_AR']!),
    Content.text(dotenv.env['TEXT_6_EN']!),
    Content.text(dotenv.env['TEXT_6_AR']!),
    Content.text(dotenv.env['TEXT_7_EN']!),
    Content.text(dotenv.env['TEXT_7_AR']!),
  ];
}
