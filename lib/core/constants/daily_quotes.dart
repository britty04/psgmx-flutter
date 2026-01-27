// Curated local quotes to replace API dependency
class DailyQuotes {
  static const List<String> quotes = [
    // 1-10
    "Small daily progress beats rare brilliance.",
    "Consistency today saves panic later.",
    "You don’t need motivation. You need routine.",
    "Excellence is not an act, but a habit.",
    "Discipline is choosing between what you want now and what you want most.",
    "The expert in anything was once a beginner.",
    "Focus on the process, not just the outcome.",
    "Your future is created by what you do today.",
    "Prepare like you have an interview tomorrow.",
    "Code is like humor. When you have to explain it, it’s bad.",
    
    // 11-20
    "Simplicity is the soul of efficiency.",
    "Make it work, make it right, make it fast.",
    "First, solve the problem. Then, write the code.",
    "Experience is the name everyone gives to their mistakes.",
    "Knowledge is power.",
    "Stay hungry, stay foolish.",
    "The best way to predict the future is to create it.",
    "It always seems impossible until it’s done.",
    "Opportunities don't happen, you create them.",
    "Don't watch the clock; do what it does. Keep going.",

    // 21-30
    "Success doesn't just find you. You have to go out and get it.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Dream bigger. Do bigger.",
    "Don't stop when you're tired. Stop when you're done.",
    "Wake up with determination. Go to bed with satisfaction.",
    "Do something today that your future self will thank you for.",
    "Little things make big days.",
    "It’s going to be hard, but hard does not mean impossible.",
    "Don’t wait for opportunity. Create it.",
    "Sometimes later becomes never. Do it now.",
    
    // 31-40
    "Great things never come from comfort zones.",
    "Dream it. Wish it. Do it.",
    "Success makes you happy, but failure makes you wise.",
    "Your time is limited, so don’t waste it living someone else’s life.",
    "If you want to achieve greatness stop asking for permission.",
    "Things work out best for those who make the best of how things work out.",
    "To live a creative life, we must lose our fear of being wrong.",
    "If you are not willing to risk the usual you will have to settle for the ordinary.",
    "Trust because you are willing to accept the risk, not because it's safe or certain.",
    "Good things come to people who wait, but better things come to those who go out and get them.",
    
    // 41-50
    "If you do what you always did, you will get what you always got.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "Just when the caterpillar thought the world was ending, he turned into a butterfly.",
    "Successful entrepreneurs are givers and not takers of positive energy.",
    "Whenever you see a successful person you only see the public glories, never the private sacrifices to reach them.",
    "Opportunities don't happen. You create them.",
    "Try not to become a person of success, but rather try to become a person of value.",
    "Great minds discuss ideas; average minds discuss events; small minds discuss people.",
    "I have not failed. I've just found 10,000 ways that won't work.",
    "If you don't value your time, neither will others. Stop giving away your time and talents--start charging for it.",

    // 51-60
    "A successful man is one who can lay a firm foundation with the bricks others have thrown at him.",
    "No one can make you feel inferior without your consent.",
    "The whole secret of a successful life is to find out what is one's destiny to do, and then do it.",
    "If you're going through hell keep going.",
    "What seems to us as bitter trials are often blessings in disguise.",
    "The distance between insanity and genius is measured only by success.",
    "When you stop chasing the wrong things, you give the right things a chance to catch you.",
    "Don't be afraid to give up the good to go for the great.",
    "No masterpiece was ever created by a lazy artist.",
    "Happiness is not something readymade. It comes from your own actions."
  ];

  static String getQuoteForToday() {
    final now = DateTime.now();
    // Calculate day of year (1-365/366)
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % quotes.length;
    return quotes[index];
  }
  
  static String getAuthorForToday() {
    return "Daily Wisdom";
  }
}
