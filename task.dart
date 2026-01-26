import 'dart:math' as math;

void main() {
  List<String> sentences = [
    "this is a test this is",
    "hello hello world",
    "dart is fun fun fun",
  ];

  Map<String, int> globalFreq = {};

  print("Highest word frequency per sentence:");

  for (int i = 0; i < sentences.length; i++) {
    //seprate by space, store in list words as words of the string sentence
    List<String> words = sentences[i].split(" ");
    //map for each words the number of times it appears
    Map<String, int> freq = {};
    //if word appears in map 1st time add 1 to count, else if already exists ++
    for (var word in words) {
      if (freq.containsKey(word)) {
        freq[word] = freq[word]! + 1;
      } else {
        freq[word] = 1;
      }
      // now for the global count , does the same thing on a global scale adding all sentences max
      if (globalFreq.containsKey(word)) {
        globalFreq[word] = globalFreq[word]! + 1;
      } else {
        globalFreq[word] = 1;
      }
    }

    //     int maxFreq = freq.values.reduce((a, b) => a > b ? a : b);
    int maxFreq = freq.values.reduce(math.max);
    List<String> maxWords = freq.entries
        .where((e) => e.value == maxFreq)
        .map((e) => e.key)
        .toList();

    print(
      '$maxWords (appears in sentence ${i + 1}) and appears $maxFreq times',
    );
  }
  
  int overallMax = globalFreq.values.reduce(math.max);

  List<String> overallWords = globalFreq.entries
      .where((e) => e.value == overallMax)
      .map((e) => e.key)
      .toList();

  print("\nOverall highest frequency word(s):");
  print('$overallWords (appears $overallMax times)');
}