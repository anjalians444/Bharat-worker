class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({required this.question, required this.options, required this.correctIndex});
}

final List<QuizQuestion> sampleQuizQuestions = [
  QuizQuestion(
    question: 'What should you do before starting any job?',
    options: [
      'Call the customer',
      'Inform admin',
      'Greet the customer and explain your process',
      'Ask for payment',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which of these is important for safety?',
    options: [
      'Working fast',
      'Using the right tools properly',
      'Wearing fancy clothes',
      'Skipping safety gear',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'When is it okay to cancel a job?',
    options: [
      "If you don't feel like it",
      'In case of emergency with prior notice',
      'Anytime',
      'Never',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Why is customer feedback important?',
    options: [
      "It's optional",
      'To argue with the customer',
      'For fun',
      'It builds trust and improves job quality',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'What helps you get more jobs?',
    options: [
      'Good reviews and certifications',
      'Ignoring messages',
      'Working without updating status',
      'Cancelling jobs',
    ],
    correctIndex: 0,
  ),
]; 