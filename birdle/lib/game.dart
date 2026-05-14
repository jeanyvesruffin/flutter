/// Logique de jeu et types de support pour Birdle,
/// un jeu de devinettes de mots de cinq lettres similaire à Wordle.
///
/// Définit la machine à états [Game] et le modèle de données
/// [Word], [Letter], et [HitType] utilisé pour
/// représenter les tentatives et leur évaluation par rapport à un mot caché.
library;

import 'dart:collection';
import 'dart:math';

/// Le résultat de l'évaluation d'une [Letter] (lettre) d'une tentative par rapport au mot caché.
enum HitType {
  /// La lettre n'a pas encore été évaluée.
  none,

  /// La lettre correspond à celle du mot caché à la même position.
  hit,

  /// La lettre est dans le mot caché, mais à une position différente.
  partial,

  /// La lettre n'apparaît pas dans le mot caché.
  miss,
}

/// Un caractère unique associé à son [HitType] par rapport au mot caché.
typedef Letter = ({String char, HitType type});

/// Tous les mots qui peuvent être légalement saisis comme tentative.
const List<String> allLegalGuesses = [...legalWords, ...legalGuesses];

/// Mots pouvant être choisis comme mot caché.
const List<String> legalWords = ['aback', 'abase', 'abate', 'abbey', 'abbot'];

/// Mots supplémentaires acceptés comme tentatives au-delà de ceux dans [legalWords].
const List<String> legalGuesses = [
  'aback',
  'abase',
  'abate',
  'abbey',
  'abbot',
  'abhor',
  'abide',
  'abled',
  'abode',
  'abort',
];

/// État du jeu d'une seule manche de Birdle,
/// un jeu de devinettes de mots de cinq lettres similaire à Wordle.
///
/// Expose l'état et les méthodes dont une interface utilisateur a besoin pour
/// évaluer les tentatives et suivre la progression,
/// mais ne fait pas avancer le jeu de lui-même.
///
/// Les clients pilotent chaque manche en appelant [guess] pour soumettre une tentative et
/// [resetGame] pour recommencer.
class Game {
  /// Le nombre maximum par défaut de tentatives autorisées dans un [Game].
  static const int defaultMaxGuesses = 5;

  /// Crée une nouvelle partie avec [maxGuesses] tentatives autorisées.
  ///
  /// Si [seed] (graine) est fourni, le mot caché est
  /// choisi de manière déterministe à partir de [legalWords],
  /// sinon il est sélectionné au hasard.
  Game({this.maxGuesses = defaultMaxGuesses, this.seed})
    : _wordToGuess = _generateInitialWord(seed),
      _guesses = List<Word>.filled(maxGuesses, Word.empty());

  /// Le nombre maximum de tentatives autorisées dans cette partie.
  final int maxGuesses;

  /// La graine utilisée pour choisir le mot caché,
  /// ou `null` s'il a été sélectionné au hasard.
  final int? seed;

  /// Le mot caché actuel, exposé publiquement via [hiddenWord].
  Word _wordToGuess;

  /// Stockage interne pour [guesses].
  ///
  /// Contient chaque emplacement de tentative dans l'ordre,
  /// les emplacements non remplis étant représentés par des [Word] vides.
  List<Word> _guesses;

  /// Le mot que le joueur essaie de deviner.
  Word get hiddenWord => _wordToGuess;

  /// Une vue non modifiable de chaque emplacement de tentative, y compris ceux encore vides.
  UnmodifiableListView<Word> get guesses => UnmodifiableListView(_guesses);

  /// La tentative soumise la plus récente,
  /// ou un [Word] vide si aucune tentative n'a été faite.
  Word get previousGuess {
    final index = _guesses.lastIndexWhere((word) => word.isNotEmpty);
    return index == -1 ? Word.empty() : _guesses[index];
  }

  /// L'index du prochain emplacement de tentative vide, ou `-1` si tous les emplacements sont pleins.
  int get activeIndex => _guesses.indexWhere((word) => word.isEmpty);

  /// Le nombre de tentatives encore disponibles pour le joueur.
  int get guessesRemaining {
    if (activeIndex == -1) return 0;
    return maxGuesses - activeIndex;
  }

  /// Indique si la tentative la plus récente correspond au mot caché.
  bool get didWin {
    if (_guesses.first.isEmpty) return false;

    for (final letter in previousGuess) {
      if (letter.type != HitType.hit) return false;
    }

    return true;
  }

  /// Indique si toutes les tentatives autorisées ont été utilisées sans gagner.
  bool get didLose => guessesRemaining == 0 && !didWin;

  /// Choisit un nouveau mot caché et efface chaque tentative soumise.
  void resetGame() {
    _wordToGuess = _generateInitialWord(seed);
    _guesses = List<Word>.filled(maxGuesses, Word.empty());
  }

  /// Évalue [guess] par rapport au mot caché,
  /// enregistre le résultat dans [guesses], et le retourne.
  ///
  /// Pour un contrôle plus précis, utilisez [isLegalGuess] pour valider la saisie ou
  /// [matchGuessOnly] pour évaluer sans enregistrer le résultat.
  Word guess(String guess) {
    final result = matchGuessOnly(guess);
    addGuessToList(result);
    return result;
  }

  /// Indique si [guess] est un mot valide à tenter.
  ///
  /// Les interfaces utilisateur peuvent appeler cette méthode avant [guess] pour
  /// afficher un message aux joueurs lorsqu'ils saisissent un mot invalide.
  bool isLegalGuess(String guess) => Word.fromString(guess).isLegalGuess;

  /// Évalue [guess] par rapport au mot caché sans faire avancer le jeu.
  Word matchGuessOnly(String guess) =>
      Word.fromString(guess).evaluateGuess(_wordToGuess);

  /// Stocke [guess] dans le prochain emplacement vide de [guesses].
  void addGuessToList(Word guess) {
    final guessIndex = activeIndex;
    if (guessIndex == -1) {
      throw StateError('Aucune tentative restante.');
    }

    _guesses[guessIndex] = guess;
  }

  /// Retourne le mot caché de départ pour une nouvelle manche.
  ///
  /// Choisit un mot déterministe dans [legalWords] lorsque [seed] est fourni,
  /// ou un mot au hasard sinon.
  static Word _generateInitialWord(int? seed) =>
      seed == null ? Word.random() : Word.fromSeed(seed);
}
/// Un mot de cinq lettres composé de [Letter]s, chacune suivant son [HitType].
class Word with IterableMixin<Letter> {
  /// Crée un mot soutenu par la liste spécifiée de [Letter]s.
  Word(this._letters);

  /// Crée un mot avec cinq lettres vides de type [HitType.none].
  factory Word.empty() =>
      Word(List<Letter>.filled(5, (char: '', type: HitType.none)));

  /// Crée un [Word] à partir d'une chaîne [guess].
  ///
  /// Chaque caractère est mis en minuscule,
  /// chaque [Letter] commence avec le type [HitType.none].
  factory Word.fromString(String guess) {
    if (guess.length != 5) {
      throw ArgumentError.value(
        guess,
        'guess',
        'Doit comporter exactement 5 caractères.',
      );
    }

    final letters = guess
        .toLowerCase()
        .split('')
        .map((char) => (char: char, type: HitType.none))
        .toList();
    return Word(letters);
  }

  /// Crée un mot choisi au hasard dans [legalWords].
  factory Word.random() {
    final random = Random();
    final nextWord = legalWords[random.nextInt(legalWords.length)];
    return Word.fromString(nextWord);
  }

  /// Crée un mot choisi dans [legalWords] en utilisant [seed] comme index.
  factory Word.fromSeed(int seed) =>
      Word.fromString(legalWords[seed % legalWords.length]);

  /// Une liste non modifiable de [Letter]s qui composent ce mot.
  final List<Letter> _letters;

  @override
  Iterator<Letter> get iterator => _letters.iterator;

  /// Indique si chaque [Letter] de ce mot n'a pas de caractère.
  @override
  bool get isEmpty => every((letter) => letter.char.isEmpty);

  @override
  int get length => _letters.length;

  /// La [Letter] à l'index [i] dans le mot.
  Letter operator [](int i) => _letters[i];

  @override
  String toString() => _letters.map((letter) => letter.char).join().trim();

  /// Retourne une chaîne multi-lignes montrant chaque [Letter] à côté de son [HitType].
  ///
  /// Utilisé pour jouer au jeu depuis la ligne de commande.
  String toStringVerbose() => _letters
      .map((letter) => '${letter.char} - ${letter.type.name}')
      .join('\n');
}

/// Logique de validation et d'évaluation des tentatives sur [Word].
extension WordUtils on Word {
  /// Indique si ce mot apparaît dans [allLegalGuesses].
  bool get isLegalGuess => allLegalGuesses.contains(toString());

  /// Compare ce [Word] au [hiddenWord] spécifié
  /// et retourne un nouveau [Word] avec les mêmes lettres,
  /// mais où chaque [Letter] a un nouveau [HitType] parmi
  /// [HitType.hit], [HitType.partial], ou [HitType.miss].
  Word evaluateGuess(Word hiddenWord) {
    assert(isLegalGuess);

    final result = List<Letter>.filled(length, (char: '', type: HitType.none));
    // Compte les lettres du mot caché qui peuvent encore être réclamées comme correspondances partielles.
    final unmatchedHiddenLetterCounts = <String, int>{};

    // Réserve les correspondances exactes (hits) avant de calculer les correspondances partielles.
    for (var i = 0; i < length; i++) {
      final guessChar = this[i].char;
      final hiddenChar = hiddenWord[i].char;

      if (guessChar == hiddenChar) {
        result[i] = (char: guessChar, type: HitType.hit);
      } else {
        // Suit les lettres cachées sans correspondance exacte pour la passe des correspondances partielles.
        final unmatchedCount = unmatchedHiddenLetterCounts[hiddenChar] ?? 0;
        unmatchedHiddenLetterCounts[hiddenChar] = unmatchedCount + 1;
      }
    }

    // Utilise chaque lettre cachée restante une seule fois pour les correspondances partielles.
    for (var i = 0; i < length; i++) {
      if (result[i].type == HitType.hit) continue;

      final guessChar = this[i].char;
      final unmatchedCount = unmatchedHiddenLetterCounts[guessChar] ?? 0;
      final isPartial = unmatchedCount > 0;
      if (isPartial) {
        // Utilise une lettre cachée disponible pour cette correspondance partielle.
        unmatchedHiddenLetterCounts[guessChar] = unmatchedCount - 1;
      }

      result[i] = (
        char: guessChar,
        type: isPartial ? HitType.partial : HitType.miss,
      );
    }

    return Word(result);
  }
}