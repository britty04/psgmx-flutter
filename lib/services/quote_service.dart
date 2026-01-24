import '../core/constants/daily_quotes.dart';

class QuoteService {
  Future<Map<String, String>> getDailyQuote() async {
    // Return deterministic local quote
    return {
      'text': DailyQuotes.getQuoteForToday(),
      'author': DailyQuotes.getAuthorForToday(),
    };
  }
}
