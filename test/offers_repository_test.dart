/// La chaîne complète de l'étape 2 : un texte partagé arrive, il est analysé,
/// scoré, dédupliqué, et enregistré.
library;

import 'package:candid/data/database.dart';
import 'package:candid/data/offers_repository.dart';
import 'package:candid/domain/scoring.dart';
import 'package:candid/sources/shared_text.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late OffersRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = OffersRepository(db);
  });
  tearDown(() => db.close());

  Future<SaveResult> share(String text, {Prefs prefs = const Prefs()}) async {
    final parsed = parseSharedText(text);
    return repo.save(
      source: parsed.source,
      title: parsed.title!,
      company: parsed.company,
      description: parsed.rawText,
      url: parsed.url,
      prefs: prefs,
    );
  }

  test('partager une offre l\'enregistre, avec son score', () async {
    final result = await share(
      'Développeur IA Junior chez ACME\n'
      'Python, machine learning, CDI, télétravail hybride.\n'
      'https://www.linkedin.com/jobs/view/1',
    );

    expect(result.outcome, SaveOutcome.saved);
    expect(result.score, greaterThan(0));

    final offers = await db.select(db.offers).get();
    expect(offers.single.company, 'ACME');
    expect(offers.single.source, 'linkedin');
    // Le texte partagé est conservé : c'est lui qu'on donnera à l'agent.
    expect(offers.single.description, contains('machine learning'));
  });

  test('la même offre partagée deux fois ne rentre qu\'une fois', () async {
    const text = 'Développeur IA Junior chez ACME\nhttps://exemple.fr/1';
    expect((await share(text)).outcome, SaveOutcome.saved);
    expect((await share(text)).outcome, SaveOutcome.duplicate);
    expect(await db.select(db.offers).get(), hasLength(1));
  });

  test('la même offre vue sur deux sites reste un doublon : le hash ignore la '
      'source et la mise en forme', () async {
    await share('Développeur IA Junior (H/F) chez ACME SAS\nhttps://linkedin.com/1');
    final second = await share(
      'Developpeur IA Junior F/H chez Acme\nhttps://fr.indeed.com/2',
    );

    expect(second.outcome, SaveOutcome.duplicate);
    expect(await db.select(db.offers).get(), hasLength(1));
  });

  test('une offre exclue par le profil n\'est pas enregistrée', () async {
    final prefs = Prefs.fromProfile(exclusions: 'PHP');
    final result = await share(
      'Développeur PHP Symfony chez ACME\nhttps://exemple.fr/3',
      prefs: prefs,
    );

    expect(result.outcome, SaveOutcome.excluded);
    expect(await db.select(db.offers).get(), isEmpty);
  });
}
