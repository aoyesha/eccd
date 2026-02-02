enum EccdLanguage { english, tagalog }

class EccdQuestions {
  static const List<String> domains = [
    'Gross Motor',
    'Fine Motor',
    'Self Help',
    'Dressing',
    'Toilet',
    'Receptive Language',
    'Expressive Language',
    'Cognitive',
    'Social Emotional',
  ];

  static EccdLanguage fromLabel(String label) {
    return label.toLowerCase().contains('tag') ? EccdLanguage.tagalog : EccdLanguage.english;
  }

  static List<String> get(String domain, EccdLanguage lang) {
    final map = (lang == EccdLanguage.english) ? _english : _tagalog;
    return map[domain] ?? const <String>[];
  }

  // ENGLISH
  // counts:
  // gross 13, fine 11, selfhelp 13, dressing 5, toilet 9,
  // receptive 5, expressive 8, cognitive 21, socio 24
  static const Map<String, List<String>> _english = {
    'Gross Motor': [
      'Climbs on chair or other elevated piece of furniture like a bed without help',
      'Walks backwards',
      'Runs without tripping or falling',
      'Walks up steps alternating feet while holding onto the guide rail',
      'Walks up steps alternating feet without holding onto the guide rail',
      'Walks down steps alternating feet without holding onto the guide rail',
      'Runs without tripping or falling (fast and smoothly)',
      'Jumps in place',
      'Hops 1–3 times using the preferred foot',
      'Jumps and turns around',
      'Moves body parts when instructed',
      'Dances/follows steps in a group activity with guidance',
      'Kicks a stationary ball with direction',
    ],

    'Fine Motor': [
      'Shows preference for using one hand more than the other',
      'Pulls toys/food toward self',
      'Picks up objects using thumb and index finger (pincer grasp)',
      'Places/removes small objects using fingers',
      'Removes cap/lid from container; peels or opens food packaging',
      'Holds crayon using a closed fist grip',
      'Scribbles spontaneously',
      'Draws vertical and horizontal lines',
      'Draws a circle shape',
      'Draws a person (head, eyes, body, arms, hands, legs, feet)',
      'Draws different shapes (e.g., square, triangle)',
    ],

    // self-help (feeding / drinking / prep) = items 1–13
    'Self Help': [
      'Feeds self with finger food (e.g. biscuits, bread) using fingers',
      'Feeds self using fingers to eat rice/viands with spillage',
      'Feeds self using spoon with spillage',
      'Feeds self using fingers without spillage',
      'Feeds self using spoon without spillage',
      'Eats without need for spoonfeeding during any meal',
      'Helps hold cup for drinking',
      'Drinks from cup with spillage',
      'Drinks from cup unassisted',
      'Gets drink for self unassisted',
      'Pours from pitcher without spillage',
      'Prepares own food/snack',
      'Prepares meals for younger siblings/family members when no adult is around',
    ],

    // dressing = items 14–18
    'Dressing': [
      'Participates when being dressed (e.g., raises arms or lifts leg)',
      'Pulls down gartered short pants',
      'Removes sando',
      'Dresses without assistance except for buttons and tying',
      'Dresses without assistance including buttons and tying',
    ],

    // toilet + hygiene/bathing = items 19–27 (9 items)
    'Toilet': [
      'Informs the adult only after he has already urinated (peed) or moved his bowels (poohed) in his underpants',
      'Informs the adult of need to urinate (pee) or move bowels (pooh-pooh) so he can be brought to a designated place (e.g., comfort room)',
      'Goes to the designated place to urinate (pee) or move bowels (pooh) but sometimes still does this in his underpants',
      'Goes to the designated place to urinate (pee) or move bowels (pooh) and never does this in his underpants anymore',
      'Wipes/cleans self after a bowel movement (pooh)',
      'Participates when bathing (e.g., rubbing arms with soap)',
      'Bathes without any help',
      'Washes and dries hands without any help',
      'Washes face without any help',
    ],

    'Receptive Language': [
      'Points to family members or familiar people/objects when asked',
      'Points to 5 body parts when instructed',
      'Points to 5 named pictures of objects',
      'Follows a 1-step instruction with a simple preposition (e.g., on top, under)',
      'Follows a 2-step instruction with a simple preposition',
    ],

    'Expressive Language': [
      'Uses 5–20 recognizable words',
      'Names objects seen in a picture (at least 4)',
      'Uses 2–3 verb–noun combinations (e.g., “want milk”)',
      'Uses pronouns (e.g., I, me, mine)',
      'Speaks in correct 2–3 word sentences',
      'Describes a recent experience (when asked) in sequence using past tense words',
      'Asks “what” questions',
      'Asks “who” and “why” questions',
    ],

    'Cognitive': [
      'Looks toward the direction of a falling object',
      'Finds objects that are partially hidden',
      'Finds objects that are completely hidden',
      'Gives objects but does not let go',
      'Imitates actions that he/she has only seen',
      'Engages in pretend play',
      'Matches objects',
      'Matches 2–3 colors',
      'Matches pictures',
      'Identifies same vs different shapes',
      'Sorts objects by 2 attributes (e.g., size and shape)',
      'Arranges objects from smallest to biggest',
      'Names 4–6 colors',
      'Copies/draws a design',
      'Names 3 animals or vegetables when asked',
      'States the uses of household objects',
      'Creates a simple design/pattern',
      'Understands opposite words by completing a sentence (e.g., “The dog is big, the mouse is ___”)',
      'Points to the left or right side of the body',
      'Tells what is wrong in a picture',
      'Matches uppercase and lowercase letters',
    ],

    'Social Emotional': [
      'Approaches unfamiliar people but may be shy or uneasy at first',
      'Watches people/animals doing activities nearby with interest',
      'Plays alone but prefers to stay near familiar adults or siblings',
      'Laughs/squeals loudly during play',
      'Plays “peek-a-boo”',
      'Rolls a ball to a playmate',
      'Hugs toys',
      'Imitates what adults do (e.g., cooking, washing)',
      'Can wait (e.g., during handwashing, getting food)',
      'Asks permission to play with a toy being used by another child',
      'Shares own toys with others',
      'Plays fairly in group games (e.g., does not cheat to win)',
      'Protects/guards possessions with determination',
      'Persists when there is a problem or obstacle to what he/she wants',
      'Is curious but knows when to stop asking questions',
      'Comforts a friend/sibling who has a problem',
      'Cooperates in group situations to prevent fights or issues',
      'Expresses heavy feelings (e.g., anger, sadness)',
      'Uses culturally appropriate gestures without being told (e.g., mano, kiss)',
      'Shows respect to elders using honorifics (e.g., “po/opo” or equivalent) instead of first name',
      'Helps with household chores (e.g., wiping the table, watering plants)',
      'Responsibly watches younger siblings/family members',
      'Accepts agreements made by caregiver (e.g., clean room before playing outside)',
      'Cooperates with older and younger people in situations to avoid conflict',
    ],
  };

  // TAGALOG
  // counts:
  // gross 13, fine 11, selfhelp 13, dressing 5, toilet 9,
  // receptive 5, expressive 8, cognitive 21, socio 24
  static const Map<String, List<String>> _tagalog = {
    'Gross Motor': [
      'Umakyat ng mga silya.',
      'Lumakad ng paurong.',
      'Bumaba ng hagdan habang hawak ng tagapag-alaga ang isang kamay.',
      'Umakyat ng hagdan na salitan ang mga paa bawat baitang, habang humahawak sa gabay ng hagdan.',
      'Umakyat ng hagdan na salitan ang mga paa na hindi humahawak sa gabay ng hagdan.',
      'Bumaba ng hagdan na salitan ang mga paa na hindi na humahawak sa gabay ng hagdan.',
      'Tumatakbo na hindi nadadapa.',
      'Tumatalon.',
      'Lumulundag ng 1-3 beses gamit ang mas gustong paa.',
      'Tumatalon at umiikot.',
      'Ginagalaw ang mga parte ng katawan kapag inuutusan.',
      'Sumasayaw/sumusunod sa mga hakbang sa sayaw, grupong gawain ukol sa kilos at galaw.',
      'Hinahagis ang bola palit-atas na may direksyon.',
    ],

    'Fine Motor': [
      'Nagpapakita ng higit pagkagusto sa paggamit ng partikular na kamay.',
      'Kinakabig ang mga laruan o pagkain.',
      'Kinukuha ang mga bagay gamit ang hinlalaki at hintuturo.',
      'Nilalagay/tinatanggal ang maliit na bagay mula sa hintuturo.',
      'Tinatanggal ang takip ng bote/lalagyan, inaalis ang balat ng pagkain.',
      'Hinahawakan ang krayola gamit ang nakasarang palad.',
      'Kusang gumuguhit-guhit.',
      'Gumuguhit ng patayo at pahalang na marka.',
      'Kusang gumuguhit ng bilog na hugis.',
      'Gumuguhit ng larawan ng tao (ulo, mata, katawan, braso, kamay, hita, paa).',
      'Gumuguhit ng bagay gamit ang iba\'t-ibang uri ng hugis (parisukat, tatsulok).',
    ],

    // self-help (feeding / drinking / prep) = 1–13
    'Self Help': [
      'Pinapakain ang sarili ng mga pagkain tulad ng biskwit at tinapay (finger food).',
      'Pinapakain ang sarili ng ulam at kanin gamit ang mga daliri ngunit may natatapon na pagkain.',
      'Pinapakain ang sarili gamit ang kutsara ngunit may natatapon na pagkain.',
      'Pinapakain ang sarili gamit ang mga daliri na walang natatapon na pagkain.',
      'Pinapakain ang sarili gamit ang kutsara na walang natatapon na pagkain.',
      'Tumutulong sa paghawak ng baso/tasa sa pag-inom.',
      'Umiinom sa baso ngunit may natatapon.',
      'Umiinom sa baso na walang umaalalay.',
      'Kumukuha ng inumin ng mag-isa.',
      'Kumakain hindi na kailangang subuan pa.',
      'Binubuhos ang tubig (o anumang likido) mula sa pitsel na walang natatapon.',
      'Naghahandang sariling pagkain/meryenda.',
      'Naghahandang pagkain para sa nakababatang kapatid/ibang miyembro ng pamilya kung walang matanda sa bahay.',
    ],

    // dressing = 14–18
    'Dressing': [
      'Nakikipagtulungan kung binibihisan (hal. itinataas ang mga kamay at paa).',
      'Hinuhubad ang shorts na may garter.',
      'Hinuhubad ang sando.',
      'Binibihisan ang sarili na walang tumutulong, maliban sa pagbubutones at pagtatali.',
      'Binibihisan ang sarili na walang tumutulong, kasama na ang pagbubutones at pagtatali.',
    ],

    // toilet + hygiene/bathing = 19–27 (9)
    'Toilet': [
      'Ipinapakita o ipinapakita o ipinapahiwatig na nahiihi o nadudumi sa shorts.',
      'Pinapaalam sa tagapag-alaga ang pangangailangang umihi o dumumi ngunit paminsan-minsan ay may pagkakataong hindi mapigilang mahihi o madumi sa shorts.',
      'Pumupunta sa tamang lugar upang umihi o dumumi ngunit paminsan-minsan ay may pagkakataong hindi mapigilang mahihi o madumi sa shorts.',
      'Matagumpay na pumupunta sa tamang lugar upang umihi o dumumi.',
      'Pinupunasan ang sarili pagkatapos dumumi.',
      'Nakikipagtulungan kung pinapaliguan (hal. kinukuskos ang mga braso).',
      'Naliligo ng walang tumutulong.',
      'Naghuhugas at nagpupunas ng mga kamay ng walang tumutulong.',
      'Naghihilamos ng mukha ng walang tumutulong.',
    ],

    'Receptive Language': [
      'Tinuturo ang mga kapamilya o pamilya na bagay kapag ipinapaturo.',
      'Tinuturo ang 5 parte ng katawan kung inutusan.',
      'Tinuturo ang 5 napangalanang larawan ng mga bagay.',
      'Sumusunod sa isang label na utos na may simpleng pang-ukol (hal. sa ibabaw, sa ilalim).',
      'Sumusunod sa dalawang label na utos na may simpleng pang-ukol.',
    ],

    'Expressive Language': [
      'Gumagamit ng 5-20 nakikilalang salita.',
      'Napapangalanan ang mga bagay na nakikita sa larawan (4).',
      'Gumagamit ng 2-3 kombinasyong pandiwa-pantangi (verb-noun combinations) (hal. Hingi pera).',
      'Gumagamit ng panghalip (hal. Ako, akin).',
      'Nagsasalita sa tamang pangungusap na may 2-3 salita.',
      'Kinukwento ang mga katatapos na karanasan (kapagtinanong/dinidiktahan) na naaayon sa pagkasunod-sunod ng pangyayari gamit ang mga salitang tumutukoy sa pangnakaraan (past tense).',
      'Nagtatanong ng ano.',
      'Nagtatanong ng sino at bakit.',
    ],

    'Cognitive': [
      'Tinitingnan ang direksyon ng nahuhulog na bagay.',
      'Hinahanap ang mga bagay na bahagyang nakatago.',
      'Hinahanap ang mga bagay na lubusang nakatago.',
      'Binibigay ang mga bagay ngunit hindi ito binibitawan.',
      'Ginagaya ang mga kilos na nakakita pa lamang.',
      'Naglalarong kunwari-kunwarian.',
      'Tinutugma ang mga bagay.',
      'Tinutugma ang 2-3 kulay.',
      'Tinutugma ang mga larawan.',
      'Nakikilala ang magkapareho at magkaibang hugis.',
      'Inaayos ang mga bagay ayon sa 2 katangian (hal. laki at hugis).',
      'Inaayos ang mga bagay mula sa pinakamaliit hanggang sa pinakamalaki.',
      'Pinapangalanan ang 4-6 na kulay.',
      'Gumuguhit/ginagaya ang isang disenyo.',
      'Pinapangalanan ang 3 hayop o gulay kapag tinatanong.',
      'Sinasabi ang mga gamit ng mga bagay sa bahay.',
      'Nakakabuo ng isang disenyo.',
      'Naiintindihan ang magkasalungat na mga salita sa pamamagitan ng pagkumpleto ng pangungusap. (hal. Ang aso ay malaki ang daga ay ____.)',
      'Tinuturo ang kaliwa o kanang bahagi ng katawan.',
      'Nasasabi kung ano ang mali sa larawan. (hal. Ano ang mali sa larawan?)',
      'Tinutugma ang malaki sa maliit na mga titik.',
    ],

    'Social Emotional': [
      'Lumalapit sa mga hindi kakilala ngunit sa una ay maaaring maging mahiyain o hindi mapalagay.',
      'Natutuwa/nanonood ng mga ginagawa ng mga tao o hayop sa malapit na lugar.',
      'Naglalarong mag-isa ngunit gusting malapit sa mga pamilyar na nakatatanda o kapatid.',
      'Tumatawa/tumitili nang malakas sa paglalaro.',
      'Naglalaro ng “bulaga”.',
      'Pinapagulong ang bola sa kalaro.',
      'Niyayakap ang mga laruan.',
      'Ginagaya ang mag ginagawang mga nakatatanda (hal. Pagluluto, Paghuhugas).',
      'Marunong maghintay (hal. Sa paghuhugas ng kamay, sa pagkuha ng pagkain).',
      'Humihingi ng permiso na laruin ang laruan ng ginagamit ng ibang bata.',
      'Pinahihiram ang sariling laruan sa iba.',
      'Naglalaro ng maayos sa mga pang-grupong laro (hal. Hindi nandadaya para manalo).',
      'Binabantayan ang mga pag-aari ng may determinasyon.',
      'Nagpupursige kung may problema o hadlang sa kanyang gusto.',
      'Interesado sa kanyang kapaligiran ngunit alam kung kailan kailangang huminto sa pagtatanong.',
      'Inaalo/inaaliw ang mga kalaro o kapatid na may problema.',
      'Nakikipagtulungan sa mga pang-grupong sitwasyon upang maiwasan ang mga away o problema.',
      'Naikukwento ang mga mabigat na nararamdaman (hal. Galit, lungkot).',
      'Gumagamit ng mga kilos na nararapat sa kultura na hindi na hinihiling/dinidiktahan (hal. Pagmamano, paghalik).',
      'Nagpapakita ng respeto sa nakatatanda gamit ang “Nang” o “Nong”, “Opo” o “Po” (o anumang katumbas nito) sa halip na kanilang unang pangalan.',
      'Tutulong sa mga gawaing pambahay (hal. Nagpupunas ng mesa, nagdidilig ng mga halaman).',
      'Responsableng nagbabantay sa mga nakababatang kapatid/miyembro ng pamilya.',
      'Tinatanggap ang isang kasunduang ginawa ng tagapag-alaga (hal. Lilinisin muna ang kuwato bago maglaro sa labas).',
      'Nakikipagtulungan sa mga nakatatanda at nakababata sa anumang sitwasyon upang maiwasan ang bangayan.',
    ],
  };
}
