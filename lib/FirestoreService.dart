import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;








  Future<List<Map<String, dynamic>>> getQuestions() async {
    var questionsSnapshot = await _db.collection('questions').orderBy('id').get();

    List<Map<String, dynamic>> questions = questionsSnapshot.docs.map((doc) {
      final data = doc.data();

      // Ensure fields are retrieved safely
      final id = data['id'] ?? 0; // Default to 0 if id is missing
      final category = data['category'] ?? 'Unknown'; // Default category
      final questionText = data['question_text'] ?? 'Pas de texte disponible'; // Default question text
      final reponses = data['reponses'] as List<dynamic>? ?? []; // Default to empty list

      // Debug print for the question data
      print('Données de la question ${id}: $data');

      // Format responses safely
      List<Map<String, dynamic>> formattedResponses = reponses.map((reponse) {
        return {
          "texte": reponse['texte'] ?? 'Pas de texte disponible',
          "points": reponse['points'] ?? 0, // Default points to 0 if missing
        };
      }).toList();

      // Print formatted responses to debug
      print('reponses formatées pour la question ${id}: $formattedResponses');

      return {
        "id": id,
        "category": category,
        "question_text": questionText,
        "reponses": formattedResponses,
      };
    }).toList();

    // Log retrieved questions
    print("Questions récupérées :");
    for (var question in questions) {
      print(question);
    }

    return questions;
  }

  Future<Map<String, dynamic>?> _fetchResponses(String userId, String theme) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      // Access theme data
      var themeData = data['themes'][theme];

      return {
        'maleResponses': List<String>.from(themeData['maleResponses']),
        'femaleResponses': List<String>.from(themeData['femaleResponses']),
        'questionResults': List<String>.from(themeData['questionResults']),
        'percentage': themeData['percentage'],
      };
    } else {
      print("User document does not exist!");
      return null; // Return null if the document doesn't exist
    }
  }



  Future<Map<String, dynamic>> getUserResponsesAndResults(String userId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> userThemesData = {};

      // Check if 'themes' exists in the user data
      if (userData['themes'] is Map<String, dynamic>) {
        // Extract theme data
        userThemesData = userData['themes'] as Map<String, dynamic>;
      }

      return {
        'email': userData['email'],
        'maleName': userData['maleName'],
        'femaleName': userData['femaleName'],
        'maleAge': userData['maleAge'],
        'femaleAge': userData['femaleAge'],
        'themes': userThemesData,
      }; // Return the user data along with theme data
    } else {
      throw Exception('User not found');
    }
  }



  Future<double> getCompatibilityPercentage(String userId, String theme) async {
    // Fetch the user document from Firestore
    DocumentSnapshot userSnapshot = await _db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      // Cast the data to Map<String, dynamic>
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Access the themes map from the user document
      Map<String, dynamic> themes = userData['themes'] ?? {};

      // Check if the specified theme exists and retrieve the percentage
      if (themes.containsKey(theme)) {
        return themes[theme]['percentage']?.toDouble() ?? 0.0; // Return the percentage or 0 if not found
      }
    }
    return 0.0; // Default return value if user or theme not found
  }

  Future<void> addUsers() async {
    // Liste des utilisateurs à ajouter
    List<Map<String, dynamic>> allUsers = [
    {
      "email": "bainailyas@gmail.com",
      "password":"ilyas34",
    "maleName": "John",
    "femaleName": "Jane",
    "maleAge": 30,
    "femaleAge": 28,
    "themes": {
    "Relation familiale et amis": {
    "percentage": 0,
    "maleResponses": ["réponse1", "réponse2"],
    "femaleResponses": ["réponseA", "réponseB"],
    "questionResults": ["match", "neutral", "contradictory"]
  },
    "Gestion financière": {
    "percentage": 0,
    "maleResponses": ["réponse3", "réponse4"],
    "femaleResponses": ["réponseC", "réponseD"],
    "questionResults": ["match", "match", "contradictory"]
  },
    "Éducation des enfants": {
    "percentage": 0,
    "maleResponses": ["réponse5", "réponse6"],
    "femaleResponses": ["réponseE", "réponseF"],
    "questionResults": ["neutral", "match", "contradictory"]
  },
    "Intimité et sexualité": {
    "percentage": 0,
    "maleResponses": ["réponse7", "réponse8"],
    "femaleResponses": ["réponseG", "réponseH"],
    "questionResults": ["contradictory", "match", "neutral"]
  },
    "Santé et bien-être": {
    "percentage": 0,
    "maleResponses": ["réponse9", "réponse10"],
    "femaleResponses": ["réponseI", "réponseJ"],
    "questionResults": ["match", "neutral", "neutral"]
  },
    "Mode de vie": {
    "percentage": 0,
    "maleResponses": ["réponse11", "réponse12"],
    "femaleResponses": ["réponseK", "réponseL"],
    "questionResults": ["neutral", "contradictory", "match"]
  }
  }
  }
      ,
      // Ajoutez d'autres utilisateurs ici si nécessaire
    ];

    // Référence à la collection 'users'
    var usersCollection = _db.collection('users');

    // Boucle pour ajouter chaque utilisateur à Firestore
    for (var user in allUsers) {
      // Ajouter l'utilisateur à Firestore
      await usersCollection.add(user);
    }
  }
  Future<Map<String, dynamic>?> getThemeData(String userId, String theme) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      final data = doc.data();
      return data?['themes']?[theme]; // Fetch the theme-specific data
    }
    return null;
  }


  // Fonction pour ajouter des questions à Firestore
  Future<void> addQuestions() async {
    List<Map<String, dynamic>> allQuestions = [
      {
        "id": 1,
        "category": "Finance",
        "question_text": "Devons-nous avoir des comptes séparés pour les dépenses personnelles tout en partageant un compte commun pour les dépenses familiales ?",
        "reponses": [
          { "texte": "Oui, c'est mieux d'avoir des comptes séparés", "points": 6 },
          { "texte": "Non, un seul compte commun suffit", "points": 2 },
          { "texte": "Peu importe, on décide ensemble", "points": 4 }
        ]
      },
      {
        "id": 2,
        "category": "Finance",
        "question_text": "Si l’un de nous dépense plus que prévu dans une catégorie du budget (vêtements, loisirs, etc.), comment devrions-nous rééquilibrer ?",
        "reponses": [
          { "texte": "Réduire dans une autre catégorie", "points": 4 },
          { "texte": "Accepter la dépense sans rééquilibrage", "points": 2 },
          { "texte": "Discuter ensemble pour ajuster", "points": 6 }
        ]
      },
      {
        "id": 3,
        "category": "Finance",
        "question_text": "Si nous gagnons un revenu inattendu (bonus, prime, héritage), comment devrions-nous l’utiliser : épargne, dépenses, voyages, etc. ?",
        "reponses": [
          { "texte": "Le placer en épargne", "points": 6 },
          { "texte": "Faire un grand voyage", "points": 2 },
          { "texte": "Investir dans quelque chose", "points": 4 }
        ]
      },
      {
        "id": 4,
        "category": "Finance",
        "question_text": "Penses-tu que nous devrions nous fixer un budget pour les sorties et les loisirs ou bien être plus flexibles à ce sujet ?",
        "reponses": [
          { "texte": "Fixer un budget strict", "points": 6 },
          { "texte": "Être flexibles selon les envies", "points": 4 },
          { "texte": "Combiner les deux : budget et flexibilité", "points": 2 }
        ]
      },
      {
        "id": 5,
        "category": "Finance",
        "question_text": "Si l’un de nous est endetté avant le mariage, devrions-nous considérer cela comme une responsabilité commune ou individuelle ?",
        "reponses": [
          { "texte": "Responsabilité commune", "points": 6 },
          { "texte": "Responsabilité individuelle", "points": 4 },
          { "texte": "On décide selon les circonstances", "points": 2 }
        ]
      },
      {
        "id": 6,
        "category": "Finance",
        "question_text": "Si un de nous veut aider financièrement un membre de sa famille, comment devrions-nous gérer cette situation ?",
        "reponses": [
          { "texte": "Aider sans discussion", "points": 2 },
          { "texte": "En discuter avant d'aider", "points": 6 },
          { "texte": "Ne pas aider financièrement", "points": 4 }
        ]
      },
      {
        "id": 7,
        "category": "Finance",
        "question_text": "Si l’un de nous prend une décision financière sans consulter l’autre, comment devrions-nous gérer la situation ?",
        "reponses": [
          { "texte": "Accepter sans discuter", "points": 2 },
          { "texte": "Avoir une discussion", "points": 6 },
          { "texte": "Poser des limites à l'avenir", "points": 4 }
        ]
      },
      {
        "id": 8,
        "category": "Finance",
        "question_text": "Si l’un de nous veut investir dans un projet personnel, devrions-nous en discuter ensemble ou considérer cela comme une décision individuelle ?",
        "reponses": [
          { "texte": "En discuter ensemble", "points": 6 },
          { "texte": "Décision individuelle", "points": 4 },
          { "texte": "Dépend du projet", "points": 2 }
        ]
      },
      {
        "id": 9,
        "category": "Finance",
        "question_text": "Es-tu du genre à dépenser pour des marques prestigieuses, même si leur qualité ne justifie pas toujours leur prix ?",
        "reponses": [
          { "texte": "Oui, j'aime les marques prestigieuses", "points": 2 },
          { "texte": "Non, je préfère la qualité/prix", "points": 6 },
          { "texte": "Parfois selon les produits", "points": 4 }
        ]
      },
      {
        "id": 10,
        "category": "Finance",
        "question_text": "Que penses-tu des prêts entre membres de la famille ? Es-tu à l’aise avec le fait d’emprunter ou de prêter de l’argent à un proche ?",
        "reponses": [
          { "texte": "Oui, c'est normal", "points": 6 },
          { "texte": "Non, je préfère éviter", "points": 2 },
          { "texte": "Cela dépend du montant", "points": 4 }
        ]
      },
      {
        "id": 11,
        "category": "Finance",
        "question_text": "Qui devrait prendre les décisions sur l'achat d'électroménagers, de meubles et d'appareils électroniques ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 12,
        "category": "Finance",
        "question_text": "Qui devrait gérer l'entretien de la maison, les réparations, rénovations… ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6},
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 13,
        "category": "Finance",
        "question_text": "Qui devrait prendre en charge les dépenses de loisirs personnels (abonnements à des clubs, sports, hobbies) ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 14,
        "category": "Finance",
        "question_text": "Qui devrait s'occuper des investissements à long terme, des assurances et des économies ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6},
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 15,
        "category": "Finance",
        "question_text": "Qui devrait décider de la répartition des tâches ménagères, des courses et de la cuisine ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 16,
        "category": "Finance",
        "question_text": "Qui devrait prendre en charge les dépenses liées aux enfants, comme les études, les activités extrascolaires, fournitures, les vêtements… ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 17,
        "category": "Finance",
        "question_text": "Qui devrait décider de l'achat d'une maison, d'une voiture… ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6},
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 18,
        "category": "Finance",
        "question_text": "Qui devrait gérer les factures de services publics (électricité, eau, internet) et les abonnements ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 19,
        "category": "Finance",
        "question_text": "Qui devrait prendre en charge les dépenses liées aux vacances et aux voyages ?",
        "reponses": [
          { "texte": "L'homme", "points": 2 },
          { "texte": "La femme", "points": 6 },
          { "texte": "Les deux ensemble", "points": 4 }
        ]
      },
      {
        "id": 20,
        "category": "Finance",
        "question_text": "Devons-nous épargner un pourcentage fixe de notre revenu chaque mois, ou cela doit-il dépendre de nos dépenses mensuelles ?",
        "reponses": [
          { "texte": "Oui, un pourcentage fixe", "points": 6 },  // Réponse préférée
          { "texte": "Une combinaison des deux", "points": 4 },  // Réponse neutre
          { "texte": "Non, cela doit dépendre", "points": 2 }    // Réponse moins favorable
        ]
      },
      {
        "id": 21,
        "category": "Finance",
        "question_text": "Comment devrions-nous gérer les investissements en bourse ou les autres types d’investissements à risques ?",
        "reponses": [
          { "texte": "On prend les décisions ensemble", "points": 6 },  // Réponse préférée
          { "texte": "En discuter avant de prendre des risques", "points": 4 },  // Réponse neutre
          { "texte": "Chacun peut investir librement", "points": 2 }  // Réponse moins favorable
        ]
      },
    {
    "id": 22,
    "category": "Relation",
    "question_text": "Seriez-vous à l'aise d'accueillir des membres de la famille pour des séjours prolongés ?",
    "reponses": [
    { "texte": "Oui, sans problème", "points": 6 },  // Réponse préférée
        { "texte": "Oui, mais sous certaines conditions", "points": 4 },  // Réponse neutre
        { "texte": "Non, je préfère que ce soit occasionnel", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 23,
    "category": "Relation",
    "question_text": "Jusqu'à quel point pensez-vous que les parents doivent être impliqués dans l'éducation de vos enfants ?",
    "reponses": [
    { "texte": "Ils devraient être très impliqués", "points": 6 },  // Réponse préférée
        { "texte": "Ils devraient avoir un rôle modéré", "points": 4 },  // Réponse neutre
        { "texte": "Ils ne devraient pas s'impliquer trop", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 24,
    "category": "Relation",
    "question_text": "Comment gérez-vous les conflits entre votre partenaire et vos parents ?",
    "reponses": [
    { "texte": "Je favorise la communication", "points": 6 },
        { "texte": "Je prends parti pour mon partenaire", "points": 4 },
        { "texte": "Je laisse chacun régler ses problèmes", "points": 2 }
    ]
    },
    {
    "id": 25,
    "category": "Relation",
    "question_text": "Êtes-vous à l’aise de partager des informations personnelles avec les parents après le mariage ?",
    "reponses": [
    { "texte": "Oui, je suis à l’aise", "points": 6 },  // Réponse préférée
        { "texte": "Seulement certaines informations", "points": 4 },  // Réponse neutre
        { "texte": "Non, je préfère garder cela privé", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 26,
    "category": "Relation",
    "question_text": "Comment réagiriez-vous si un membre de la famille s'implique trop dans votre vie de couple ?",
    "reponses": [
    { "texte": "Je lui en parlerais calmement", "points": 6 },  // Réponse préférée
        { "texte": "Je mettrais des limites claires", "points": 4 },  // Réponse neutre
        { "texte": "Je le laisserais faire", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 27,
    "category": "Relation",
    "question_text": "Que feriez-vous si votre partenaire ne s'entend pas bien avec un de vos amis proches ?",
    "reponses": [
    { "texte": "J'essaierais de les réconcilier", "points": 6 },  // Réponse préférée
        { "texte": "Je garderais mes relations séparées", "points": 4 },  // Réponse neutre
        { "texte": "Je prendrais parti pour mon partenaire", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 28,
    "category": "Relation",
    "question_text": "Que feriez-vous si un ami vous demande de l'aide financière, mais votre partenaire est contre l'idée ?",
    "reponses": [
    { "texte": "Je respecte l'avis de mon partenaire", "points": 6 },  // Réponse préférée
        { "texte": "Je trouve un compromis", "points": 4 },  // Réponse neutre
        { "texte": "J'aide mon ami quand même", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 29,
    "category": "Relation",
    "question_text": "Que feriez-vous si vos parents veulent vous aider financièrement, mais cela crée des tensions avec votre partenaire ?",
    "reponses": [
    { "texte": "Je refuse l'aide pour préserver la paix", "points": 6 },  // Réponse préférée
        { "texte": "Je discute avec mon partenaire", "points": 4 },  // Réponse neutre
        { "texte": "J'accepte l'aide malgré tout", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 30,
    "category": "Relation",
    "question_text": "Que ferais-tu si tes parents voulaient emménager avec nous dans le futur pour des raisons de santé ou d’âge ?",
    "reponses": [
    { "texte": "J'accepterais volontiers", "points": 6 },  // Réponse préférée
        { "texte": "Je préfèrerais trouver une autre solution", "points": 4 },  // Réponse neutre
        { "texte": "Je serais contre", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 31,
    "category": "Relation",
    "question_text": "Si un de tes amis me faisait une remarque déplacée ou irrespectueuse, comment réagirais-tu ?",
    "reponses": [
    { "texte": "Je défendrais immédiatement mon partenaire", "points": 6 },  // Réponse préférée
        { "texte": "Je parlerais à mon ami en privé", "points": 4 },  // Réponse neutre
        { "texte": "Je laisserais passer", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 32,
    "category": "Relation",
    "question_text": "Si l’un de tes amis faisait souvent des blagues inappropriées à mon sujet, comment réagirais-tu ?",
    "reponses": [
    { "texte": "Je lui demanderais d'arrêter immédiatement.", "points": 6 },  // Réponse préférée
        { "texte": "J'expliquerais que cela me met mal à l'aise.", "points": 4 },  // Réponse neutre
        { "texte": "Je le prendrais à part pour discuter.", "points": 4 },  // Réponse neutre
        { "texte": "J'ignorerais si c'était une seule fois.", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 33,
    "category": "Relation",
    "question_text": "Que penses-tu de l’idée de vivre avec tes parents pendant un certain temps si cela devenait nécessaire pour des raisons financières ou de santé ?",
    "reponses": [
    { "texte": "Je serais d'accord si c'était temporaire.", "points": 6 },  // Réponse préférée
        { "texte": "J'accepterais mais avec des limites.", "points": 4 },  // Réponse neutre
        { "texte": "Je ne serais pas à l'aise avec l'idée.", "points": 2 },  // Réponse moins favorable
        { "texte": "Je refuserais complètement.", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 34,
    "category": "Relation",
    "question_text": "Comment réagirais-tu si ta famille me critiquait constamment, même pour des choses mineures ?",
    "reponses": [
    { "texte": "Je défendrais notre relation.", "points": 6 },  // Réponse préférée
        { "texte": "Je leur demanderais d'arrêter.", "points": 4 },  // Réponse neutre
        { "texte": "Je prendrais tes remarques en considération.", "points": 4 },  // Réponse neutre
        { "texte": "Je les ignorerais.", "points": 2 }  // Réponse moins favorable
    ]
    },
    {
    "id": 35,
    "category": "Relation",
    "question_text": "Comment réagirais-tu si je n'invitais pas certains de tes amis ou membres de ta famille à un événement important comme notre mariage ?",
    "reponses": [
    { "texte": "Je serais très contrarié.", "points": 6 },  // Réponse préférée
        { "texte": "Je te demanderais pourquoi.", "points": 4 },  // Réponse neutre
        { "texte": "Je pourrais comprendre si tu as une bonne raison" }
    ]
    }
    ,
        {
          "id": 36,
          "category": "Relation",
          "question_text": "Comment te sentirais-tu si j'étais un fils / fille à maman, et que cela prenait beaucoup de notre temps ?",
          "reponses": [
            {"texte": "Je serais frustré(e).", "points": 6},
            {"texte": "Je te parlerais pour trouver un équilibre.", "points": 4},
            {"texte": "Je serais compréhensif/ve dans certaines situations.", "points": 2},
            {"texte": "Je n'y prêterais pas beaucoup d'attention.", "points": 0}
          ]
        },
        {
          "id": 37,
          "category": "Relation",
          "question_text": "Comment te sentirais-tu si je confiais des détails personnels de notre relation à mes amis ?",
          "reponses": [
            {"texte": "Je me sentirais trahi(e).", "points": 6},
            {"texte": "Je te demanderais de ne pas le refaire.", "points": 4},
            {"texte": "Je pourrais comprendre si c'est pour avoir des conseils.", "points": 2},
            {"texte": "Je ne m'en soucierais pas trop.", "points": 0}
          ]
        },
        {
          "id": 38,
          "category": "Relation",
          "question_text": "Comment réagirais-tu si je me confiais plus à un de mes amis qu'à toi sur des sujets sensibles ?",
          "reponses": [
            {"texte": "Je serais blessé(e).", "points": 6},
            {"texte": "Je te demanderais de me parler directement.", "points": 4},
            {"texte": "Je pourrais comprendre selon le sujet.", "points": 2},
            {"texte": "Cela ne me dérangerait pas trop.", "points": 0}
          ]
        },
        {
          "id": 39,
          "category": "Relation",
          "question_text": "Que penses-tu d'avoir des amis du sexe opposé ?",
          "reponses": [
            {"texte": "Je n'ai aucun problème avec cela.", "points": 6},
            {"texte": "Je suis d'accord tant qu'il y a des limites.", "points": 4},
            {"texte": "Cela pourrait me rendre jaloux(se).", "points": 2},
            {"texte": "Je n'accepterais pas.", "points": 0}
          ]
        },
        {
          "id": 40,
          "category": "Relation",
          "question_text": "Es-tu d'accord pour que j'invite souvent mes amis chez nous ?",
          "reponses": [
            {"texte": "Oui, cela me convient.", "points": 6},
            {"texte": "Je préfère que ce soit de temps en temps.", "points": 4},
            {"texte": "Je voudrais que ce soit rare.", "points": 2},
            {"texte": "Je n'aime pas l'idée.", "points": 0}
          ]
        },
        {
          "id": 41,
          "category": "Relation",
          "question_text": "Que penserais-tu si je décidais de passer un week-end entier avec mes amis sans toi ?",
          "reponses": [
            {"texte": "Je serais d'accord si c'est occasionnel.", "points": 6},
            {"texte": "Je serais d'accord mais avec des limites.", "points": 4},
            {"texte": "Je me sentirais exclu(e).", "points": 2},
            {"texte": "Je n'accepterais pas cela.", "points": 0}
          ]
        },
        {
          "id": 42,
          "category": "Relation",
          "question_text": "Es-tu d'accord si le gars joue beaucoup à la PlayStation avec ses amis, faire du shopping pendant des heures pour les filles ?",
          "reponses": [
            {"texte": "Oui, chacun son loisir.", "points": 6},
            {"texte": "Tant que cela reste équilibré.", "points": 4},
            {"texte": "Je préférerais que cela soit modéré.", "points": 2},
            {"texte": "Je ne serais pas d'accord.", "points": 0}
          ]
        },
        {
          "id": 43,
          "category": "Relation",
          "question_text": "Es-tu d'accord si un gars joue beaucoup à la PlayStation avec ses amis, tout comme une fille qui fait du shopping pendant des heures avec ses amies ?",
          "reponses": [
            {"texte": "Oui, cela me va.", "points": 6},
            {"texte": "Oui, tant que c'est équilibré.", "points": 4},
            {"texte": "Je serais un peu jaloux(se).", "points": 2},
            {"texte": "Non, je n'accepterais pas.", "points": 0}
          ]
        },
        {
          "id": 44,
          "category": "Relation",
          "question_text": "Que ferais-tu si je devais choisir entre passer du temps avec toi ou avec mes amis ?",
          "reponses": [
            {"texte": "Je préférerais que tu choisisses moi.", "points": 6},
            {"texte": "Je te laisserais choisir librement.", "points": 4},
            {"texte": "Je serais un peu déçu(e) si tu choisissais tes amis.", "points": 2},
            {"texte": "Je ne me soucierais pas trop.", "points": 0}
          ]
        },
        {
          "id": 45,
          "category": "Relation",
          "question_text": "Que ferais-tu si je te demandais de ne pas venir à un événement où mes amis seront présents ?",
          "reponses": [
            {"texte": "Je serais blessé(e).", "points": 6},
            {"texte": "Je te demanderais pourquoi.", "points": 4},
            {"texte": "Je respecterais ta demande.", "points": 2},
            {"texte": "Je n'en ferais pas une affaire.", "points": 0}
          ]
        },
        {
          "id": 46,
          "category": "Relation",
          "question_text": "Que ferais-tu si un de mes amis te critiquait ouvertement devant moi ?",
          "reponses": [
            {"texte": "Je te demanderais de réagir.", "points": 6},
            {"texte": "Je répondrais directement à la personne.", "points": 4},
            {"texte": "J'ignorerais pour éviter un conflit.", "points": 2},
            {"texte": "Je partirais sans dire un mot.", "points": 0}
          ]
        },
        {
          "id": 47,
          "category": "Relation",
          "question_text": "Que penserais-tu si j'acceptais l'amitié d'un(e) ex sur les réseaux sociaux ?",
          "reponses": [
            {"texte": "Je ne serais pas content(e).", "points": 6},
            {"texte": "Je te demanderais pourquoi tu l'as fait.", "points": 4},
            {"texte": "Je serais peut-être un peu jaloux(se).", "points": 2},
            {"texte": "Cela ne me dérangerait pas.", "points": 0}
          ]
        }
      ,
      {
        "id": 49,
        "category": "MaisonRole",
        "question_text": "Qui fait le ménage hebdomadaire (nettoyage général) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 50,
        "category": "MaisonRole",
        "question_text": "Qui nettoie la cuisine après la préparation des repas ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 51,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe des poubelles ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 52,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de la lessive (laver, sécher, plier) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 53,
        "category": "MaisonRole",
        "question_text": "Qui change les draps et fait les lits ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 54,
        "category": "MaisonRole",
        "question_text": "Qui gère l'entretien de la voiture (nettoyage intérieur et extérieur) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 55,
        "category": "MaisonRole",
        "question_text": "Qui gère le nettoyage des bacs à litière pour les animaux de compagnie ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 56,
        "category": "MaisonRole",
        "question_text": "Qui est responsable de l'organisation des placards et tiroirs ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 57,
        "category": "MaisonRole",
        "question_text": "Qui est chargé de l'organisation des vacances (préparer les bagages, vérifier les réservations) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 58,
        "category": "MaisonRole",
        "question_text": "Qui fait le suivi des dates d'expiration des produits alimentaires ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 59,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de trier et de ranger les fournitures scolaires des enfants ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 60,
        "category": "MaisonRole",
        "question_text": "Qui est chargé de gérer les demandes de réparation à domicile (plombier, électricien) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      }
      ,
      {
        "id": 61,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de vérifier et de renouveler les fournitures de nettoyage ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 62,
        "category": "MaisonRole",
        "question_text": "Qui est responsable de décider de l'achat des décorations et des meubles ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 63,
        "category": "MaisonRole",
        "question_text": "Qui prend en charge l'organisation des documents importants (contrats, factures) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 64,
        "category": "MaisonRole",
        "question_text": "Qui est chargé de s'assurer que les enfants participent aux tâches ménagères ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 65,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de la planification des repas hebdomadaires ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 66,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de la planification des repas pour les occasions spéciales ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 67,
        "category": "MaisonRole",
        "question_text": "Qui est responsable de l'achat de médicaments et de fournitures de santé ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 68,
        "category": "MaisonRole",
        "question_text": "Qui s'occupe de la planification des activités en extérieur (randonnées, pique-niques) ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 69,
        "category": "MaisonRole",
        "question_text": "Qui est chargé de l'organisation des projets de bricolage à la maison ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 70,
        "category": "MaisonRole",
        "question_text": "Qui gère le tri et le rangement des photos et albums de famille ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 71,
        "category": "MaisonRole",
        "question_text": "Qui s'assure que les enfants respectent l'heure du coucher et de lever ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 72,
        "category": "MaisonRole",
        "question_text": "Qui prend en charge la gestion des dépenses et de l'épargne familiale ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 73,
        "category": "MaisonRole",
        "question_text": "Qui s'assure que les courses alimentaires sont faites régulièrement ?",
        "reponses": [
          {"texte": "L'homme", "points": 2},
          {"texte": "La femme", "points": 6},
          {"texte": "Les deux", "points": 4}
        ]
      },
      {
        "id": 74,
        "category": "Sexe",
        "question_text": "Quelles sont vos préférences en matière de fréquence des rapports intimes ?",
        "reponses": [
          {"texte": "Tous les jours", "points": 6},
          {"texte": "Quelques fois par semaine", "points": 4},
          {"texte": "Une fois par semaine", "points": 2},
          {"texte": "Rarement", "points": 0}
        ]
      },
      {
        "id": 75,
        "category": "Sexe",
        "question_text": "Comment pouvez-vous aborder la communication autour de vos besoins sexuels ?",
        "reponses": [
          {"texte": "Je parle directement", "points": 6},
          {"texte": "Je fais des suggestions subtiles", "points": 4},
          {"texte": "J'attends le bon moment", "points": 2},
          {"texte": "Je préfère éviter d'en parler", "points": 0}
        ]
      },
      {
        "id": 76,
        "category": "Sexe",
        "question_text": "Quels rôles jouent la romance et la séduction dans votre relation ?",
        "reponses": [
          {"texte": "C'est essentiel", "points": 6},
          {"texte": "C'est important mais pas primordial", "points": 4},
          {"texte": "Nous y pensons rarement", "points": 2}
        ]
      },
      {
        "id": 77,
        "category": "Sexe",
        "question_text": "Comment aborderiez-vous ensemble l'exploration de fantasmes ou de scénarios ?",
        "reponses": [
          {"texte": "Avec ouverture et curiosité", "points": 6},
          {"texte": "En en parlant progressivement", "points": 4},
          {"texte": "Je préfère éviter ce sujet", "points": 2}
        ]
      },
      {
        "id": 78,
        "category": "Sexe",
        "question_text": "Comment envisagez-vous la répartition des responsabilités concernant la contraception ?",
        "reponses": [
          {"texte": "C'est une responsabilité partagée", "points": 6},
          {"texte": "Je m'en occupe", "points": 4},
          {"texte": "Mon partenaire s'en occupe", "points": 2}
        ]
      },
      {
        "id": 79,
        "category": "Sexe",
        "question_text": "Quelle importance accordez-vous à l'affection physique en dehors des rapports sexuels ?",
        "reponses": [
          {"texte": "C'est très important", "points": 6},
          {"texte": "Ça compte mais pas tout le temps", "points": 4},
          {"texte": "Je peux m'en passer", "points": 2}
        ]
      },
      {
        "id": 80,
        "category": "Sexe",
        "question_text": "Pensez-vous que l’humour peut avoir un impact positif sur votre vie sexuelle ?",
        "reponses": [
          {"texte": "Oui, ça détend l'atmosphère", "points": 6},
          {"texte": "Peut-être, selon la situation", "points": 4},
          {"texte": "Non, ce n'est pas nécessaire", "points": 2}
        ]
      },
      {
        "id": 81,
        "category": "Sexe",
        "question_text": "Est-ce que votre partenaire vous attire sexuellement ?",
        "reponses": [
          {"texte": "Absolument", "points": 6},
          {"texte": "Oui, mais ça dépend des moments", "points": 4},
          {"texte": "Pas vraiment", "points": 2}
        ]
      },
      {
        "id": 82,
        "category": "Sexe",
        "question_text": "Est-ce que la taille ça compte ?",
        "reponses": [
          {"texte": "Oui, c'est important", "points": 6},
          {"texte": "Un peu, mais pas crucial", "points": 4},
          {"texte": "Pas du tout", "points": 2}
        ]
      },
      {
        "id": 83,
        "category": "Sexe",
        "question_text": "Comment vous assurez-vous que votre partenaire se sente désiré et apprécié ?",
        "reponses": [
          {"texte": "Je le dis souvent", "points": 6},
          {"texte": "Je le montre par mes actions", "points": 4},
          {"texte": "Je pense qu'il/elle le sait déjà", "points": 2}
        ]
      },
      {
        "id": 84,
        "category": "Sexe",
        "question_text": "Comment les vacances ou les escapades peuvent-elles influencer votre intimité ?",
        "reponses": [
          {"texte": "Elles ravivent la passion", "points": 6},
          {"texte": "Elles apportent un peu de nouveauté", "points": 4},
          {"texte": "Peu d'effet sur nous", "points": 2}
        ]
      },
      {
        "id": 85,
        "category": "Sexe",
        "question_text": "Seriez-vous intéressé à tester l'intimité dans des endroits insolites (voitures, plages, ou d'autres lieux inattendus) ?",
        "reponses": [
          {"texte": "Oui, c'est excitant", "points": 6},
          {"texte": "Peut-être, selon les conditions", "points": 4},
          {"texte": "Non, je préfère l'intimité à la maison", "points": 2}
        ]
      },
      {
        "id": 86,
        "category": "Sexe",
        "question_text": "Les préliminaires et le toucher sont-ils essentiels pour exciter votre partenaire ?",
        "reponses": [
          {"texte": "Oui, toujours", "points": 6},
          {"texte": "Parfois, mais pas toujours", "points": 4},
          {"texte": "Pas nécessairement", "points": 2}
        ]
      },
      {
        "id": 87,
        "category": "Sexe",
        "question_text": "Comment prévoyez-vous de gérer les changements physiques qui peuvent affecter votre vie intime ?",
        "reponses": [
          {"texte": "Avec patience et compréhension", "points": 6},
          {"texte": "On en discutera si nécessaire", "points": 4},
          {"texte": "Je préfère ne pas y penser", "points": 2}
        ]
      },
      {
        "id": 88,
        "category": "Sexe",
        "question_text": "Quel rôle jouent les surprises dans votre vie intime ?",
        "reponses": [
          {"texte": "J'adore les surprises", "points": 6},
          {"texte": "De temps en temps", "points": 4},
          {"texte": "Je n'aime pas être surpris", "points": 2}
        ]
      },
      {
        "id": 89,
        "category": "Sexe",
        "question_text": "Comment abordez-vous la question des pratiques sexuelles que l'un de vous ne souhaite pas essayer ?",
        "reponses": [
          {"texte": "Avec respect et compréhension", "points": 6},
          {"texte": "Je tente de convaincre doucement", "points": 4},
          {"texte": "Je préfère ne pas en parler", "points": 2}
        ]
      },
      {
        "id": 90,
        "category": "Sexe",
        "question_text": "Comment gérez-vous les moments où l'un de vous est moins intéressé par l'intimité ?",
        "reponses": [
          {"texte": "Avec patience", "points": 6},
          {"texte": "On en parle ouvertement", "points": 4},
          {"texte": "On évite le sujet", "points": 2}
        ]
      },
      {
        "id": 91,
        "category": "Sexe",
        "question_text": "Quelle place accordez-vous aux massages ou aux caresses dans votre vie intime ?",
        "reponses": [
          {"texte": "Très important, c'est un essentiel", "points": 6},
          {"texte": "J'aime en recevoir de temps en temps", "points": 4},
          {"texte": "Pas vraiment nécessaire", "points": 2}
        ]
      },
      {
        "id": 92,
        "category": "Sexe",
        "question_text": "Comment assurez-vous une communication claire pendant l'acte ?",
        "reponses": [
          {"texte": "Je parle ouvertement", "points": 6},
          {"texte": "Je fais des suggestions discrètes", "points": 4},
          {"texte": "Je ne dis pas grand-chose", "points": 2}
        ]
      },
      {
        "id": 93,
        "category": "Sexe",
        "question_text": "Est-ce que vous avez des préoccupations concernant la performance ou l'anxiété liée à l'intimité ?",
        "reponses": [
          {"texte": "Non, je suis confiant", "points": 6},
          {"texte": "Parfois, mais j'en parle", "points": 4},
          {"texte": "Oui, souvent", "points": 2}
        ]
      },
      {
        "id": 94,
        "category": "Sexe",
        "question_text": "Comment gérez-vous la jalousie ou l'insécurité dans votre relation ?",
        "reponses": [
          {"texte": "On en parle toujours", "points": 6},
          {"texte": "Je gère seul", "points": 4},
          {"texte": "C'est un sujet délicat", "points": 2}
        ]
      },
      {
        "id": 95,
        "category": "Sexe",
        "question_text": "Quelle importance accordez-vous à la créativité dans votre vie intime ?",
        "reponses": [
          {"texte": "C'est essentiel", "points": 6},
          {"texte": "C'est agréable de temps en temps", "points": 4},
          {"texte": "Pas très important", "points": 2}
        ]
      },
      {
        "id": 96,
        "category": "Sexe",
        "question_text": "Êtes-vous à l'aise d'aborder des sujets sensibles comme l'anxiété ou la douleur pendant l'intimité ?",
        "reponses": [
          {"texte": "Oui, c'est important d'en parler", "points": 6},
          {"texte": "Je préfère en parler en dehors", "points": 4},
          {"texte": "Non, je n'en parle pas", "points": 2}
        ]
      },
      {
        "id": 97,
        "category": "Sexe",
        "question_text": "Quelle place accordez-vous à l'éducation sexuelle dans votre relation ?",
        "reponses": [
          {"texte": "C'est très important", "points": 6},
          {"texte": "Ça peut être intéressant", "points": 4},
          {"texte": "Pas nécessairement", "points": 2}
        ]
      },
      {
        "id": 98,
        "category": "Sexe",
        "question_text": "Est-ce que vous partagez les tâches liées à votre vie sexuelle (protection, contraception, etc.) ?",
        "reponses": [
          {"texte": "C'est un effort commun", "points": 6},
          {"texte": "On en parle de temps en temps", "points": 4},
          {"texte": "Pas vraiment", "points": 2}
        ]
      },
      {
        "id": 99,
        "category": "Sexe",
        "question_text": "Êtes-vous à l'aise avec l'idée d'explorer ensemble de nouveaux aspects de votre sexualité ?",
        "reponses": [
          {"texte": "Oui, avec enthousiasme", "points": 6},
          {"texte": "Peut-être, selon la situation", "points": 4},
          {"texte": "Non, je préfère rester dans ma zone de confort", "points": 2}
        ]
      },
      {
        "id": 100,
        "category": "Sexe",
        "question_text": "Quel rôle joue l'intimité émotionnelle dans votre vie sexuelle ?",
        "reponses": [
          {"texte": "C'est essentiel", "points": 6},
          {"texte": "C'est agréable mais pas nécessaire", "points": 4},
          {"texte": "Pas vraiment important", "points": 2}
        ]
      }, {
        "id": 99,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur la méditation ?",
        "reponses": [
          {"texte": "C'est essentiel pour la paix intérieure", "points": 6},
          {"texte": "J'y pense parfois", "points": 4},
          {"texte": "Je n'y crois pas trop", "points": 2}
        ]
      },
      {
        "id": 100,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous à la nature dans votre vie ?",
        "reponses": [
          {"texte": "C'est fondamental pour mon bien-être", "points": 6},
          {"texte": "J'aime m'y rendre de temps en temps", "points": 4},
          {"texte": "Je suis plus une personne d'intérieur", "points": 2}
        ]
      },
      {
        "id": 101,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur les thérapies alternatives ?",
        "reponses": [
          {"texte": "Je crois en leurs bienfaits", "points": 6},
          {"texte": "Je pense que ça peut aider", "points": 4},
          {"texte": "Je préfère la médecine traditionnelle", "points": 2}
        ]
      },
      {
        "id": 102,
        "category": "Santé",
        "question_text": "Quelle place le sport occupe-t-il dans votre vie quotidienne ?",
        "reponses": [
          {"texte": "Je fais du sport tous les jours", "points": 6},
          {"texte": "J'en fais plusieurs fois par semaine", "points": 4},
          {"texte": "Le sport n'est pas une priorité", "points": 2}
        ]
      },
      {
        "id": 103,
        "category": "Santé",
        "question_text": "Pensez-vous que faire du sport ensemble renforce une relation ?",
        "reponses": [
          {"texte": "Absolument, cela crée des liens", "points": 6},
          {"texte": "Ça peut être amusant", "points": 4},
          {"texte": "Je préfère faire du sport seul", "points": 2}
        ]
      },
      {
        "id": 104,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous aux repas faits maison ?",
        "reponses": [
          {"texte": "Très important, je cuisine toujours", "points": 6},
          {"texte": "J'apprécie, mais pas toujours", "points": 4},
          {"texte": "Je préfère manger à l'extérieur", "points": 2}
        ]
      },
      {
        "id": 105,
        "category": "Santé",
        "question_text": "Accepteriez que votre partenaire fasse un tatouage un jour ?",
        "reponses": [
          {"texte": "Oui, c'est son choix", "points": 6},
          {"texte": "Je n'aime pas trop, mais c'est acceptable", "points": 4},
          {"texte": "Je ne serais pas à l'aise avec ça", "points": 2}
        ]
      },
      {
        "id": 106,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous à l'hygiène de vie globale ?",
        "reponses": [
          {"texte": "C'est une priorité", "points": 6},
          {"texte": "J'essaie de faire attention", "points": 4},
          {"texte": "Je n'y prête pas trop attention", "points": 2}
        ]
      },
      {
        "id": 107,
        "category": "Santé",
        "question_text": "Quelle est votre approche face aux problèmes de peau ?",
        "reponses": [
          {"texte": "Je consulte régulièrement un dermatologue", "points": 6},
          {"texte": "J'utilise des soins spécifiques", "points": 4},
          {"texte": "Je n'y prête pas beaucoup d'attention", "points": 2}
        ]
      },
      {
        "id": 108,
        "category": "Santé",
        "question_text": "Quelle est votre approche concernant le temps d'écran ?",
        "reponses": [
          {"texte": "Je limite strictement mon temps d'écran", "points": 6},
          {"texte": "Je fais attention, mais pas trop", "points": 4},
          {"texte": "Je ne me soucie pas vraiment du temps d'écran", "points": 2}
        ]
      },
      {
        "id": 109,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous à l'expression de la gratitude dans votre vie ?",
        "reponses": [
          {"texte": "Très important, je l'exprime chaque jour", "points": 6},
          {"texte": "Je l'exprime de temps en temps", "points": 4},
          {"texte": "Je n'y pense pas souvent", "points": 2}
        ]
      },
      {
        "id": 110,
        "category": "Santé",
        "question_text": "Avez-vous des allergies alimentaires ?",
        "reponses": [
          {"texte": "Oui, plusieurs", "points": 6},
          {"texte": "Oui, une ou deux", "points": 4},
          {"texte": "Non, aucune", "points": 2}
        ]
      },
      {
        "id": 111,
        "category": "Santé",
        "question_text": "Quelle place donnez-vous aux repas en famille ?",
        "reponses": [
          {"texte": "Très important, c'est un rituel", "points": 6},
          {"texte": "J'apprécie, mais pas toujours", "points": 4},
          {"texte": "Peu d'importance pour moi", "points": 2}
        ]
      },
      {
        "id": 112,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous aux examens médicaux réguliers ?",
        "reponses": [
          {"texte": "Je fais des examens réguliers", "points": 6},
          {"texte": "Je consulte un médecin de temps en temps", "points": 4},
          {"texte": "Je vais rarement chez le médecin", "points": 2}
        ]
      },
      {
        "id": 113,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur le rôle de l'humour dans la santé ?",
        "reponses": [
          {"texte": "L'humour est essentiel à la santé", "points": 6},
          {"texte": "Ça aide parfois", "points": 4},
          {"texte": "Je ne pense pas que ça ait un grand impact", "points": 2}
        ]
      },
      {
        "id": 114,
        "category": "Santé",
        "question_text": "Quelle place accordez-vous à la musique dans votre bien-être ?",
        "reponses": [
          {"texte": "La musique est vitale pour moi", "points": 6},
          {"texte": "J'écoute de la musique souvent", "points": 4},
          {"texte": "Je peux m'en passer", "points": 2}
        ]
      },
      {
        "id": 115,
        "category": "Santé",
        "question_text": "Quelle importance accordez-vous à la spiritualité dans votre vie ?",
        "reponses": [
          {"texte": "Très important, c'est central", "points": 6},
          {"texte": "Ça joue un rôle mineur", "points": 4},
          {"texte": "Pas d'importance pour moi", "points": 2}
        ]
      },
      {
        "id": 116,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur l’impact des réseaux sociaux sur la santé ?",
        "reponses": [
          {"texte": "C'est néfaste pour la santé mentale", "points": 6},
          {"texte": "Ça peut avoir des effets négatifs", "points": 4},
          {"texte": "Je ne pense pas que ce soit un problème", "points": 2}
        ]
      },
      {
        "id": 117,
        "category": "Santé",
        "question_text": "Accepteriez-vous que votre partenaire fume ou boive de l'alcool ?",
        "reponses": [
          {"texte": "Oui, je respecte ses choix", "points": 6},
          {"texte": "Je préférerais qu'il/elle ne le fasse pas", "points": 4},
          {"texte": "Je ne pourrais pas l'accepter", "points": 2}
        ]
      },
      {
        "id": 118,
        "category": "Santé",
        "question_text": "Êtes-vous à l'aise avec votre apparence actuelle ?",
        "reponses": [
          {"texte": "Oui, je me sens bien dans ma peau", "points": 6},
          {"texte": "C'est correct, mais j'aimerais changer quelques choses", "points": 4},
          {"texte": "Non, je ne suis pas satisfait(e)", "points": 2}
        ]
      },
      {
        "id": 119,
        "category": "Santé",
        "question_text": "Attendez-vous la validation des autres pour vous sentir accepté ?",
        "reponses": [
          {"texte": "Non, je me valide moi-même", "points": 6},
          {"texte": "Un peu, ça compte pour moi", "points": 4},
          {"texte": "Oui, j'ai besoin de la validation des autres", "points": 2}
        ]
      },
      {
        "id": 120,
        "category": "Santé",
        "question_text": "Préférez-vous un style vestimentaire décontracté ou élégant ?",
        "reponses": [
          {"texte": "Décontracté", "points": 6},
          {"texte": "Un mélange des deux", "points": 4},
          {"texte": "Élégant", "points": 2}
        ]
      },
      {
        "id": 121,
        "category": "Santé",
        "question_text": "Pensez-vous qu'il est important de prendre soin de son apparence pour plaire à son partenaire ?",
        "reponses": [
          {"texte": "Oui, c'est une marque de respect.", "points": 6},
          {"texte": "C'est bien, mais pas une obligation.", "points": 4},
          {"texte": "Chacun doit se sentir à l'aise avec son apparence.", "points": 2}
        ]
      },
      {
        "id": 122,
        "category": "Santé",
        "question_text": "Comment réagissez-vous si votre partenaire change radicalement de style ?",
        "reponses": [
          {"texte": "J'accepte son choix.", "points": 6},
          {"texte": "Je serais surpris, mais je m'adapterais.", "points": 4},
          {"texte": "Cela pourrait me perturber.", "points": 2}
        ]
      },
      {
        "id": 123,
        "category": "Santé",
        "question_text": "Accepteriez-vous que votre partenaire vous demande de ne pas poster de photos sur les réseaux sociaux ?",
        "reponses": [
          {"texte": "Oui, je comprends la demande.", "points": 6},
          {"texte": "Cela dépend de la raison.", "points": 4},
          {"texte": "Non, je préfère partager librement.", "points": 2}
        ]
      },
      {
        "id": 124,
        "category": "Santé",
        "question_text": "Êtes-vous sensible aux tendances de la mode, ou préférez-vous un style personnel ?",
        "reponses": [
          {"texte": "Je préfère suivre les tendances.", "points": 6},
          {"texte": "Je mélange les deux.", "points": 4},
          {"texte": "Je préfère un style personnel.", "points": 2}
        ]
      },
      {
        "id": 125,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur le maquillage et son rôle dans l'apparence ?",
        "reponses": [
          {"texte": "C'est un moyen d'expression.", "points": 6},
          {"texte": "C'est bien, mais pas indispensable.", "points": 4},
          {"texte": "Je préfère la beauté naturelle.", "points": 2}
        ]
      },
      {
        "id": 126,
        "category": "Santé",
        "question_text": "Quelle est votre opinion sur les choix de vêtements avec votre partenaire ?",
        "reponses": [
          {"texte": "Nous choisissons ensemble parfois.", "points": 6},
          {"texte": "Chacun fait ses choix indépendamment.", "points": 4},
          {"texte": "Nous avons des goûts différents, mais je respecte.", "points": 2}
        ]
      }, {
        "id": 127,
        "category": "ModeVie",
        "question_text": "Préférez-vous vivre en ville ou à la campagne ?",
        "reponses": [
          { "texte": "Ville, j'aime l'énergie.", "points": 6 },
          { "texte": "Campagne, j'aime la tranquillité.", "points": 2 },
          { "texte": "Les deux, selon le moment.", "points": 4 }
        ]
      },
      {
        "id": 128,
        "category": "ModeVie",
        "question_text": "Êtes-vous une personne matinale ou plutôt du soir ?",
        "reponses": [
          { "texte": "Matinale, j'adore me lever tôt.", "points": 6 },
          { "texte": "Du soir, j'aime la tranquillité nocturne.", "points": 2 },
          { "texte": "Je suis flexible, ça dépend.", "points": 4 }
        ]
      },
      {
        "id": 129,
        "category": "ModeVie",
        "question_text": "Quel est votre niveau d'importance accordé à la propreté dans la maison ?",
        "reponses": [
          { "texte": "Très important, j'aime l'ordre.", "points": 6 },
          { "texte": "Je fais de mon mieux, sans stress.", "points": 4 },
          { "texte": "Je ne suis pas très strict sur ça.", "points": 2 }
        ]
      },
      {
        "id": 130,
        "category": "ModeVie",
        "question_text": "À quelle fréquence souhaitez-vous partir en vacances chaque année ?",
        "reponses": [
          { "texte": "Au moins deux fois par an.", "points": 4 },
          { "texte": "Une fois suffit.", "points": 6 },
          { "texte": "Je préfère des escapades courtes mais fréquentes.", "points": 2 }
        ]
      },
      {
        "id": 131,
        "category": "ModeVie",
        "question_text": "Quel est votre style de vie préféré : actif et aventurier ou calme et détendu ?",
        "reponses": [
          { "texte": "Actif et aventurier.", "points": 2 },
          { "texte": "Calme et détendu.", "points": 6 },
          { "texte": "Un mélange des deux.", "points": 4 }
        ]
      },
      {
        "id": 132,
        "category": "ModeVie",
        "question_text": "Préférez-vous passer du temps à l'extérieur ou à l'intérieur pendant vos moments de détente ?",
        "reponses": [
          { "texte": "À l'extérieur, j'aime la nature.", "points": 6 },
          { "texte": "À l'intérieur, j'aime le confort.", "points": 2 },
          { "texte": "Ça dépend de l'humeur.", "points": 4 }
        ]
      },
      {
        "id": 133,
        "category": "ModeVie",
        "question_text": "Êtes-vous plus à l'aise dans les grands rassemblements sociaux ou les petits groupes intimes ?",
        "reponses": [
          { "texte": "Grands rassemblements.", "points": 6 },
          { "texte": "Petits groupes intimes.", "points": 2 },
          { "texte": "Je m'adapte à l'ambiance.", "points": 4 }
        ]
      },
      {
        "id": 134,
        "category": "ModeVie",
        "question_text": "Comment aimez-vous passer vos week-ends ?",
        "reponses": [
          { "texte": "En explorant de nouveaux endroits.", "points": 6 },
          { "texte": "En me relaxant chez moi.", "points": 2 },
          { "texte": "En passant du temps avec mes proches.", "points": 4 }
        ]
      },
      {
        "id": 135,
        "category": "ModeVie",
        "question_text": "Aimez-vous sortir régulièrement ou préférez-vous rester près de chez vous ?",
        "reponses": [
          { "texte": "J'aime sortir régulièrement.", "points": 6 },
          { "texte": "Je préfère rester près de chez moi.", "points": 2 },
          { "texte": "Un équilibre entre les deux.", "points": 4 }
        ]
      },
      {
        "id": 136,
        "category": "ModeVie",
        "question_text": "Quel type d'alimentation suivez-vous : végétarien, végan, omnivore, ou autre ?",
        "reponses": [
          { "texte": "Omnivore.", "points": 2 },
          { "texte": "Végétarien.", "points": 4 },
          { "texte": "Autre", "points": 6 }
        ]
      },
      {
        "id": 137,
        "category": "ModeVie",
        "question_text": "Aimez-vous les animaux de compagnie à la maison ?",
        "reponses": [
          { "texte": "Oui, je les adore.", "points": 6 },
          { "texte": "Oui, mais avec modération.", "points": 4 },
          { "texte": "Non, je préfère sans.", "points": 2 }
        ]
      },
      {
        "id": 138,
        "category": "ModeVie",
        "question_text": "Aimez-vous planifier vos journées à l'avance ou être plus spontané(e) ?",
        "reponses": [
          { "texte": "Je planifie à l'avance.", "points": 6 },
          { "texte": "Je préfère la spontanéité.", "points": 2 },
          { "texte": "Un mélange des deux.", "points": 4 }
        ]
      },
      {
        "id": 139,
        "category": "ModeVie",
        "question_text": "Quelle importance accordez-vous à la consommation de divertissements numériques (films, séries, jeux) ?",
        "reponses": [
          { "texte": "C'est une grande partie de mon temps libre.", "points": 6 },
          { "texte": "J'en consomme modérément.", "points": 4 },
          { "texte": "Je préfère d'autres activités.", "points": 2 }
        ]
      },
      {
        "id": 140,
        "category": "ModeVie",
        "question_text": "Préférez-vous cuisiner à la maison ou manger à l'extérieur ?",
        "reponses": [
          { "texte": "Cuisiner à la maison.", "points": 6 },
          { "texte": "Manger à l'extérieur.", "points": 2 },
          { "texte": "Les deux selon l'occasion.", "points": 4 }
        ]
      },
      {
        "id": 141,
        "category": "ModeVie",
        "question_text": "Quel est votre rapport au shopping : achetez-vous souvent ou seulement l'essentiel ?",
        "reponses": [
          { "texte": "J'achète souvent.", "points": 6 },
          { "texte": "Je me limite à l'essentiel.", "points": 2 },
          { "texte": "Ça dépend de mon humeur.", "points": 4 }
        ]
      },
      {
        "id": 142,
        "category": "ModeVie",
        "question_text": "Combien de temps aimez-vous consacrer aux activités sportives chaque semaine ?",
        "reponses": [
          { "texte": "Beaucoup de temps, j'aime rester actif.", "points": 6 },
          { "texte": "Quelques heures par semaine.", "points": 4 },
          { "texte": "Peu de temps, je préfère d'autres activités.", "points": 2 }
        ]
      },
      {
        "id": 143,
        "category": "ModeVie",
        "question_text": "Quelle est votre relation avec l'argent : économe ou dépensier/dépensière ?",
        "reponses": [
          { "texte": "Je suis plutôt économe.", "points": 6 },
          { "texte": "Je dépense facilement.", "points": 2 },
          { "texte": "J'essaie de trouver un équilibre.", "points": 4 }
        ]
      },
      {
        "id": 144,
        "category": "ModeVie",
        "question_text": "Comment gérez-vous les tâches ménagères dans la vie de couple ?",
        "reponses": [
          { "texte": "Partage égal des tâches.", "points": 4 },
          { "texte": "Je prends plus en charge.", "points": 2 },
          { "texte": "Je préfère déléguer.", "points": 6 }
        ]
      },
      {
        "id": 145,
        "category": "ModeVie",
        "question_text": "Quelle place la religion ou la spiritualité occupe-t-elle dans votre quotidien ?",
        "reponses": [
          { "texte": "Très importante.", "points": 6 },
          { "texte": "Modérément présente.", "points": 4 },
          { "texte": "Peu d'importance.", "points": 2 }
        ]
      },
      {
        "id": 146,
        "category": "ModeVie",
        "question_text": "Quel est votre niveau d'attachement à la famille : très proche ou plus distant ?",
        "reponses": [
          { "texte": "Très proche, toujours en contact.", "points": 6},
          { "texte": "Proche, mais avec de la distance.", "points": 4 },
          { "texte": "Plus distant, indépendance.", "points": 2 }
        ]
      },
      {
        "id": 147,
        "category": "ModeVie",
        "question_text": "Préférez-vous vivre dans une villa spacieuse, un appartement confortable ou un espace de taille moyenne plus minimaliste ?",
        "reponses": [
          { "texte": "Villa spacieuse.", "points": 6},
          { "texte": "Appartement confortable.", "points": 4 },
          { "texte": "Espace minimaliste.", "points": 2 }
        ]
      },
      {
        "id": 148,
        "category": "ModeVie",
        "question_text": "Quel type de voiture vous attire le plus : une voiture de moyenne gamme, un modèle de luxe, ou une voiture de sport ?",
        "reponses": [
          { "texte": "Moyenne gamme, pratique.", "points": 2 },
          { "texte": "Modèle de luxe, pour le confort.", "points": 6 },
          { "texte": "Voiture de sport, pour l'adrénaline.", "points": 4 }
        ]
      },
      {
        "id": 149,
        "category": "ModeVie",
        "question_text": "Êtes-vous plutôt introverti(e) ou extraverti(e) ?",
        "reponses": [
          { "texte": "Introverti(e), je recharge seul(e).", "points": 2 },
          { "texte": "Extraverti(e), j'adore les interactions.", "points": 6 },
          { "texte": "Je suis un peu des deux.", "points": 4 }
        ]
      },
      {
        "id": 150,
        "category": "ModeVie",
        "question_text": "Préférez-vous passer du temps dans la nature ou dans un environnement festif ?",
        "reponses": [
          { "texte": "Nature, pour la tranquillité.", "points": 6 },
          { "texte": "Environnement festif, pour l'ambiance.", "points": 2 },
          { "texte": "Un peu des deux, selon l'occasion.", "points": 4 }
        ]
      },
      {
        "id": 151,
        "category": "ModeVie",
        "question_text": "Préférez-vous passer vos vacances à l’étranger ou dans votre propre pays ?",
        "reponses": [
          { "texte": "À l'étranger, pour découvrir.", "points": 6 },
          { "texte": "Dans mon pays, pour la simplicité.", "points": 2 },
          { "texte": "Je varie selon l'année.", "points": 4 }
        ]
      },
      {
        "id": 152,
        "category": "ModeVie",
        "question_text": "Que pensez-vous des vêtements de luxe qui ne valent pas leur prix ?",
        "reponses": [
          { "texte": "Pas intéressé(e), c'est trop cher.", "points": 6 },
          { "texte": "Parfois, pour la qualité.", "points": 4 },
          { "texte": "J'aime le luxe, peu importe le prix.", "points": 2 }
        ]
      },
      {
        "id": 153,
        "category": "ModeVie",
        "question_text": "Quelle importance accordez-vous au silence pour un sommeil ?",
        "reponses": [
          { "texte": "Très important, j'ai besoin de calme.", "points": 6 },
          { "texte": "Je m'adapte, avec ou sans bruit.", "points": 4 },
          { "texte": "Pas trop important, je dors bien partout.", "points": 2 }
        ]
      },
      {
        "id": 154,
        "category": "ModeVie",
        "question_text": "Aimez-vous organiser des dîners ou des soirées entre amis ?",
        "reponses": [
          { "texte": "Oui, j'adore recevoir.", "points": 6 },
          { "texte": "Parfois, selon l'humeur.", "points": 4 },
          { "texte": "Je préfère participer que d'organiser.", "points": 2 }
        ]
      },
      {
        "id": 155,
        "category": "ModeVie",
        "question_text": "Préférez-vous les films d'action, les comédies, ou les drames ?",
        "reponses": [
          { "texte": "Films d'action, pour l'adrénaline.", "points": 4 },
          { "texte": "Comédies, pour rigoler.", "points": 2 },
          { "texte": "Dramas, pour l'émotion.", "points": 6 }
        ]
      },
      {
        "id": 156,
        "category": "ModeVie",
        "question_text": "Savez-vous cuisiner ?",
        "reponses": [
          { "texte": "Oui, j'aime cuisiner.", "points": 6 },
          { "texte": "Un peu, assez pour me débrouiller.", "points": 4 },
          { "texte": "Pas vraiment, je préfère manger.", "points": 2 }
        ]
      }, {
        "id": 157,
        "category": "Enfant",
        "question_text": "Comment gérez-vous les colères ou crises de vos enfants ?",
        "reponses": [
          { "texte": "Calmer l’enfant et discuter de ses émotions.", "points": 6 },
          { "texte": "Établir des limites claires et fermes.", "points": 2 },
          { "texte": "Ignorer la crise pour ne pas encourager le comportement.", "points": 4}
        ]
      },
      {
        "id": 158,
        "category": "Enfant",
        "question_text": "Comment réagissez-vous lorsque vos enfants échouent ou rencontrent des difficultés ?",
        "reponses": [
          { "texte": "Encourager et offrir du soutien.", "points": 6},
          { "texte": "Laisser l’enfant apprendre par lui-même.", "points": 2 },
          { "texte": "Offrir des conseils et fixer de nouveaux objectifs.", "points": 4 }
        ]
      },
      {
        "id": 159,
        "category": "Enfant",
        "question_text": "Comment intégrez-vous vos enfants dans les tâches ménagères ?",
        "reponses": [
          { "texte": "Attribuer des tâches adaptées à leur âge.", "points": 6 },
          { "texte": "Impliquer l’enfant de temps en temps.", "points": 4 },
          { "texte": "Leur demander de participer quand c’est nécessaire.", "points": 2 }
        ]
      },
      {
        "id": 160,
        "category": "Enfant",
        "question_text": "Comment encouragez-vous vos enfants à être responsables de leurs devoirs scolaires ?",
        "reponses": [
          { "texte": "Les laisser libre.", "points": 2 },
          { "texte": "Vérifier régulièrement leur travail.", "points": 6 },
          { "texte": "Les laisser gérer eux-mêmes, avec supervision.", "points": 4 }
        ]
      },
      {
        "id": 161,
        "category": "Enfant",
        "question_text": "Comment équilibrez-vous le temps passé devant les écrans et les activités physiques pour vos enfants ?",
        "reponses": [
          { "texte": "Fixer des limites strictes d’utilisation d’écrans.", "points": 2 },
          { "texte": "Encourager les activités physiques avant les écrans.", "points": 4 },
          { "texte": "Interdire les écrans.", "points": 6 }
        ]
      },
      {
        "id": 162,
        "category": "Enfant",
        "question_text": "Seriez-vous favorable à l'idée de donner un téléphone à vos enfants à un jeune âge ?",
        "reponses": [
          { "texte": "Non, pas avant un âge approprié.", "points": 2 },
          { "texte": "Oui, pour des raisons de sécurité.", "points": 6 },
          { "texte": "Peut-être, avec des restrictions d’usage.", "points": 4 }
        ]
      },
      {
        "id": 163,
        "category": "Enfant",
        "question_text": "Les enfants devraient-ils fréquenter une école publique ou privée ?",
        "reponses": [
          { "texte": "École publique, pour la diversité.", "points": 2 },
          { "texte": "École privée, pour la qualité de l’éducation.", "points": 6 },
          { "texte": "Cela dépend des besoins de l’enfant.", "points": 4 }
        ]
      },
      {
        "id": 164,
        "category": "Enfant",
        "question_text": "Quelle est votre approche pour enseigner la gestion de l'argent à vos enfants ?",
        "reponses": [
          { "texte": "Leur donner une allocation pour apprendre à gérer.", "points": 6  },
          { "texte": "Les impliquer dans les décisions d’achat.", "points": 4},
          { "texte": "Ne pas leurs donner de l'argent .", "points": 2 }
        ]
      },
      {
        "id": 165,
        "category": "Enfant",
        "question_text": "Faut-il être amis avec vos enfants ?",
        "reponses": [
          { "texte": "Oui, tout en restant parent.", "points": 6 },
          { "texte": "Oui, mais avec des limites.", "points": 4 },
          { "texte": "Non, il faut garder une distance parentale.", "points": 2 }
        ]
      },
      {
        "id": 166,
        "category": "Enfant",
        "question_text": "Faut-il tout raconter à vos enfants, comme les salaires par exemple ?",
        "reponses": [
          { "texte": "Non, certains sujets doivent rester privés.", "points": 2 },
          { "texte": "Oui, pour les préparer à la vie adulte.", "points": 6 },
          { "texte": "Cela dépend de leur âge et maturité.", "points": 4 }
        ]
      },
      {
        "id": 167,
        "category": "Enfant",
        "question_text": "Faut-il punir un enfant physiquement, privilégier la discussion, le priver de quelque chose ou recourir au chantage ?",
        "reponses": [
          { "texte": "Privilégier la discussion pour comprendre.", "points": 2 },
          { "texte": "Priver de privilèges selon la faute.", "points": 6 },
          { "texte": "Éviter le chantage et la punition physique.", "points": 4 }
        ]
      },
      {
        "id": 168,
        "category": "Enfant",
        "question_text": "Qui devrait être le principal responsable de l'accompagnement scolaire des enfants ?",
        "reponses": [
          { "texte": "Les deux parents, à parts égales.", "points": 6 },
          { "texte": "Celui qui est le plus disponible.", "points": 4 },
          { "texte": "L’enseignant, avec le soutien parental.", "points": 2 }
        ]
      },
      {
        "id": 169,
        "category": "Enfant",
        "question_text": "Qui est le plus impliqué dans les devoirs à la maison ?",
        "reponses": [
          { "texte": "Les deux parents.", "points": 6 },
          { "texte": "Le parent le plus disponible.", "points": 4 },
          { "texte": "Cela varie en fonction des matières.", "points": 2 }
        ]
      },
      {
        "id": 170,
        "category": "Enfant",
        "question_text": "Qui est plus enclin à initier des discussions sur les choix de carrière avec les enfants ?",
        "reponses": [
          { "texte": "Les deux parents, ensemble.", "points": 6 },
          { "texte": "Le parent ayant le plus d’expérience professionnelle.", "points": 4 },
          { "texte": "Cela dépend de la carrière envisagée.", "points": 2 }
        ]
      },
      {
        "id": 171,
        "category": "Enfant",
        "question_text": "Qui est généralement le plus impliqué dans les réunions de parents d'élèves ?",
        "reponses": [
          { "texte": "Les deux parents, selon la disponibilité.", "points": 6 },
          { "texte": "Le parent le plus concerné par l’éducation.", "points": 2 },
          { "texte": "Cela dépend des sujets abordés.", "points": 4 }
        ]
      },
      {
        "id": 172,
        "category": "Enfant",
        "question_text": "Qui devrait établir les règles concernant l'utilisation des écrans ?",
        "reponses": [
          { "texte": "Les deux parents ensemble.", "points": 2},
          { "texte": "Celui qui est le plus informé sur le sujet.", "points": 4 },
          { "texte": "En discussion avec les enfants, selon l’âge.", "points": 6 }
        ]
      },
      {
        "id": 173,
        "category": "Enfant",
        "question_text": "Qui aborde le mieux les discussions sur la sexualité avec les enfants ?",
        "reponses": [
          { "texte": "Les deux parents, ensemble.", "points": 6 },
          { "texte": "Le parent qui se sent le plus à l’aise.", "points": 2 },
          { "texte": "Cela dépend du sujet.", "points": 4 }
        ]
      },
      {
        "id": 174,
        "category": "Enfant",
        "question_text": "Qui est le plus souvent impliqué dans le choix des vêtements des enfants ?",
        "reponses": [
          { "texte": "Les deux parents.", "points": 6 },
          { "texte": "Le parent avec le plus de goût.", "points": 2 },
          { "texte": "Cela dépend de la situation.", "points": 4 }
        ]
      },
      {
        "id": 175,
        "category": "Enfant",
        "question_text": "Qui devrait être responsable de la discipline à la maison ?",
        "reponses": [
          { "texte": "Les deux parents, à parts égales.", "points": 6 },
          { "texte": "Celui qui est le plus strict.", "points": 2 },
          { "texte": "Cela dépend des circonstances.", "points":4 }
        ]
      },
      {
        "id": 176,
        "category": "Enfant",
        "question_text": "Qui devrait être responsable de la prise de décision sur les choix alimentaires ?",
        "reponses": [
          { "texte": "Les deux parents ensemble.", "points": 6 },
          { "texte": "Celui qui cuisine le plus.", "points": 2 },
          { "texte": "ça depend .", "points": 4 }
        ]
      }
    ];

    var questionsCollection = _db.collection('questions');

    // Boucle pour ajouter chaque question à Firestore
    for (var question in allQuestions) {
      await questionsCollection.add(question);
    }
  }


}
