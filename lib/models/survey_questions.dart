// lib/models/survey_questions.dart
/// 질병명(영문) → 내부 코드 매핑
final Map<String, String> DISEASE_NAME_TO_CODE = {
  "Actinic Keratosis": "akiec",
  "Melanoma": "mel",
  "Benign Keratosis": "bkl",
  "Nevus": "nv",
  "Basal Cell Carcinoma": "bcc",
  "Dermatofibroma": "df",
  "Vascular Lesion": "vasc",
};

/// 질병명으로 질문 목록 가져오기
List<Map<String, dynamic>>? getSurveyQuestions(String diseaseName, {bool isKorean = true}) {
  final internalCode = DISEASE_NAME_TO_CODE[diseaseName];
  if (internalCode == null) return null;
  return isKorean ? SURVEY_QUESTIONS_KO[internalCode] : SURVEY_QUESTIONS_EN[internalCode];
}

final Map<String, List<Map<String, dynamic>>> SURVEY_QUESTIONS_KO = {
  "bkl": [
    {"id": 1, "question": "해당 피부 증식이 중년 이후 연령에 발생했나요?"},
    {"id": 2, "question": "병변의 표면이 밀랍처럼 광택 있고 피부에 붙어있는 모습인가요?"},
    {"id": 3, "question": "병변의 색깔이 갈색이며, 주변 피부와 비교해 뚜렷한 색조 변화가 보이나요?"},
    {"id": 4, "question": "병변이 가슴, 등, 복부, 두피, 얼굴, 목 등 햇빛 노출 부위에 생겼나요?"},
    {"id": 5, "question": "병변에 통증은 없고 가끔 가려움 정도만 있나요?"},
    {"id": 6, "question": "병변이 처음에는 작고 거친 돌기였고, 서서히 두꺼워지며 사마귀 같은 표면으로 변했나요?"},
    {"id": 7, "question": "하나의 병변만 존재하나요, 아니면 비슷한 모양의 병변이 여러 개 생겼나요?"},
    {"id": 8, "question": "겉모습 상 이 병변이 피부암과 유사하게 보인다고 느낀 적이 있나요?"},
    {"id": 9, "question": "병변이 의류나 장신구에 걸리거나 마찰되어 자주 자극을 받나요?"},
    {"id": 10, "question": "가족 중에도 유사한 양성 각화증을 다발성으로 가진 분이 있나요?"}
  ],
  "nv": [
    {"id": 1, "question": "해당 점의 색상이 균일하게 한 가지(예: 연한 갈색 또는 검은색)로 이루어져 있나요?"},
    {"id": 2, "question": "점의 모양이 대칭적이고 경계가 매끈하고 규칙적인가요?"},
    {"id": 3, "question": "점의 크기가 6mm 이하로 작고, 대체로 연필 지우개보다 작나요?"},
    {"id": 4, "question": "이 점을 어린 시절이나 젊은 성인기에 얻었으며, 최근에 새롭게 생긴 점은 아니었나요?"},
    {"id": 5, "question": "점이 생긴 후 수년간 크기나 형태, 색깔에 거의 변화가 없었나요?"},
    {"id": 6, "question": "특별한 자극이 없는데도 점 부위에 부음, 통증, 가려움, 출혈 또는 딱지가 앉는 변화가 전혀 없나요?"},
    {"id": 7, "question": "몸에 있는 점의 개수가 대략 50개 이하로, 상대적으로 많은 편은 아니신가요?"},
    {"id": 8, "question": "가족 중에 피부암, 특히 흑색종을 진단받은 분이 없나요?"},
    {"id": 9, "question": "어릴 때 심한 햇볕 화상(물집이 생길 정도의 화상)을 여러 번 입은 적이 있나요?"},
    {"id": 10, "question": "몸의 다른 점들과 비교하여 유독 눈에 띄게 다른 점이 있나요?"}
  ],
  "mel": [
    {"id": 1, "question": "해당 병변이 **불규칙한 경계**를 가지며, **대칭적이지 않나요**?"},
    {"id": 2, "question": "병변에 **여러 가지 색**(갈색, 검은색, 빨강, 파랑, 흰색 등)이 섞여 있나요?"},
    {"id": 3, "question": "병변의 **크기가 6mm 이상**으로 커졌나요?"},
    {"id": 4, "question": "병변이 최근 **크기, 색, 모양에 변화**를 보였나요?"},
    {"id": 5, "question": "해당 병변에 **통증, 출혈, 가려움** 등의 증상이 있나요?"},
    {"id": 6, "question": "해당 병변이 **새롭게 생긴 점**인가요, 아니면 기존 점이 변화한 것인가요?"},
    {"id": 7, "question": "어린 시절 **여러 차례 햇볕 화상**을 입은 적이 있나요?"},
    {"id": 8, "question": "가족 중에 **흑색종**을 진단받은 사람이 있나요?"},
    {"id": 9, "question": "병변이 **모발이 있는 부위**에 발생했나요? (두피 포함)"},
    {"id": 10, "question": "병변 주변이 **불규칙하게 솟아있거나 울퉁불퉁**한 형태인가요?"}
  ],
  "df": [
    {"id": 1, "question": "병변이 **작고 단단한 둥근 혹**으로, **주로 팔과 다리**에 생겼나요?"},
    {"id": 2, "question": "병변이 **색깔은 갈색 또는 분홍색**을 띠고 있나요?"},
    {"id": 3, "question": "병변을 **눌렀을 때 중앙이 움푹 들어가는** 느낌이 있나요?"},
    {"id": 4, "question": "이 병변이 **피부 표면**에 올라와 있나요, 아니면 **피부와 비슷한 수준**인가요?"},
    {"id": 5, "question": "병변에 **통증은 없고, 가끔 가려움** 정도만 있나요?"},
    {"id": 6, "question": "이 병변이 **여러 개** 생기기보다는 **하나**로 나타나나요?"},
    {"id": 7, "question": "가족 중에 **유사한 병변**을 가진 사람이 있나요?"},
    {"id": 8, "question": "이 병변이 **피부 자극**이나 **상처**로 인해 발생한 것 같나요?"},
    {"id": 9, "question": "병변이 **여성**에게 더 많이 발생하나요?"},
    {"id": 10, "question": "병변이 **성인기**에 처음 나타났나요?"}
  ],
  "vasc": [
    {"id": 1, "question": "병변이 **붉거나 파란색**을 띠고, **작은 혈관이 보이는** 점이 있나요?"},
    {"id": 2, "question": "병변을 **누르면 색이 연해지며** 압박을 떼면 다시 붉어지나요?"},
    {"id": 3, "question": "병변이 **여러 개** 생겨서 **군집 형태**로 나타나고 있나요?"},
    {"id": 4, "question": "병변이 **손목, 얼굴, 팔, 다리** 등 **흔히 노출되는 부위**에 생겼나요?"},
    {"id": 5, "question": "병변이 **붉은 점**처럼 보이며 **출혈**이나 **통증**이 있을 수 있나요?"},
    {"id": 6, "question": "이 병변이 **임신** 중에 갑자기 나타난 것이 있나요?"},
    {"id": 7, "question": "병변이 **어린 시절**에 생긴 것인가요?"},
    {"id": 8, "question": "병변이 **빠르게 커지거나 변화**하는 양상을 보였나요?"},
    {"id": 9, "question": "병변이 **크기가 작고** 일시적인 출혈이나 부기만 발생하나요?"},
    {"id": 10, "question": "병변의 **표면이 평평하거나 살짝 융기** 되어 있나요?"}
  ],
  "akiec": [
    {"id": 1, "question": "병변이 **햇볕에 많이 노출된 부위**에 생겼나요?"},
    {"id": 2, "question": "병변이 **붉고 건조**한 표면을 보이고 있나요?"},
    {"id": 3, "question": "병변이 **크기나 형태가 서서히 커지고 있는** 모습을 보이나요?"},
    {"id": 4, "question": "병변에 **인설**이 발생하며 **거칠고 비늘**이 붙어 있는 형태인가요?"},
    {"id": 5, "question": "병변의 **크기가 1cm 이상**으로 커졌나요?"},
    {"id": 6, "question": "병변이 **입술, 귀, 눈 주위** 같은 민감한 부위에 생겼나요?"},
    {"id": 7, "question": "병변을 **눌렀을 때, 출혈**이 생기거나 **피부가 부풀어 오른** 느낌이 있나요?"},
    {"id": 8, "question": "이 병변이 **성인기 중반 이후** 나타났다면, **경고 신호**가 될 수 있나요?"},
    {"id": 9, "question": "병변에 **통증**이나 **피부 자극**을 느낀 적이 있나요?"},
    {"id": 10, "question": "병변의 **모양이나 크기**가 일정하지 않고 **불규칙적인 모양**을 띠고 있나요?"}
  ],
  "bcc": [
    {"id": 1, "question": "병변이 **얼굴, 두피, 목, 팔 등 햇볕 노출 부위**에 생겼나요?"},
    {"id": 2, "question": "병변의 **표면이 진주색**을 띠고, **작고 단단한 결절** 모양인가요?"},
    {"id": 3, "question": "병변의 **가장자리가 불규칙하고**, **가운데가 움푹 패인** 형태인가요?"},
    {"id": 4, "question": "병변에 **출혈**이나 **진물**이 나는 등 **가끔 자극**을 받나요?"},
    {"id": 5, "question": "병변이 **서서히 자라며**, **몇 년에 걸쳐 커지고** 있나요?"},
    {"id": 6, "question": "병변이 **하얗고, 경계가 명확하지 않으며** 부풀어 오른 모습을 보이나요?"},
    {"id": 7, "question": "이 병변이 **피부에 붙어있는** 느낌이며, **마찰이나 긁을 때** 출혈이 발생할 수 있나요?"},
    {"id": 8, "question": "병변이 **50세 이상의 연령**에서 주로 발생하는 특징을 보이나요?"},
    {"id": 9, "question": "병변이 **점차 확장**되며, **얼굴에 생긴 경우** 위험할 수 있나요?"},
    {"id": 10, "question": "병변에 **통증**이나 **민감성**이 있어 자주 손상되나요?"}
  ]
};

const Map<String, List<Map<String, dynamic>>> SURVEY_QUESTIONS_EN = {

  "bkl": [
    {"id": "1", "question": "Did the skin growth appear later in middle age?"},
    {"id": "2", "question": "Does the lesion look shiny like wax and appear stuck to the skin?"},
    {"id": "3", "question": "Is the lesion brown in color with a clear contrast compared to surrounding skin?"},
    {"id": "4", "question": "Did the lesion appear on sun-exposed areas like chest, back, face, or neck?"},
    {"id": "5", "question": "Is the lesion painless, with only occasional itching?"},
    {"id": "6", "question": "Did the lesion start small and rough, then gradually thicken into a wart-like surface?"},
    {"id": "7", "question": "Is there only one lesion, or are there several with a similar appearance?"},
    {"id": "8", "question": "Have you ever thought the lesion looked like skin cancer?"},
    {"id": "9", "question": "Does it frequently get irritated by clothes or accessories?"},
    {"id": "10", "question": "Do any family members have similar multiple lesions?"}
  ],
  "nv": [
    {"id": "1", "question": "Is the mole a single, even color like light brown or black?"},
    {"id": "2", "question": "Is the mole symmetric and does it have smooth, regular borders?"},
    {"id": "3", "question": "Is the mole small (under 6mm, like the size of a pencil eraser)?"},
    {"id": "4", "question": "Did it appear in childhood or early adulthood, not recently?"},
    {"id": "5", "question": "Has the mole stayed the same in size, shape, and color for years?"},
    {"id": "6", "question": "Is there no swelling, pain, itching, bleeding, or scabbing?"},
    {"id": "7", "question": "Do you have fewer than about 50 moles on your body?"},
    {"id": "8", "question": "Does anyone in your family have melanoma or other skin cancer?"},
    {"id": "9", "question": "Have you had multiple sunburns with blisters as a child?"},
    {"id": "10", "question": "Is there one mole that looks very different from others?"}
  ],
  "mel": [
    {"id": "1", "question": "Does the lesion have irregular borders and is it asymmetrical?"},
    {"id": "2", "question": "Are there multiple colors in the lesion (brown, black, red, blue, white)?"},
    {"id": "3", "question": "Is it larger than 6mm in diameter?"},
    {"id": "4", "question": "Has it recently changed in size, color, or shape?"},
    {"id": "5", "question": "Do you feel pain, bleeding, or itching from the lesion?"},
    {"id": "6", "question": "Is it a new mole or a change in an existing one?"},
    {"id": "7", "question": "Did you have several sunburns during childhood?"},
    {"id": "8", "question": "Does anyone in your family have melanoma?"},
    {"id": "9", "question": "Did it appear in a hairy area (e.g., scalp)?"},
    {"id": "10", "question": "Does the lesion have a raised or uneven surface?"}
  ],
  "df": [
    {"id": "1", "question": "Is the lesion a small, firm, round bump usually on arms or legs?"},
    {"id": "2", "question": "Is the color brown or pink?"},
    {"id": "3", "question": "Does the center feel like it sinks in when pressed?"},
    {"id": "4", "question": "Is it raised from the skin surface or level with it?"},
    {"id": "5", "question": "Is it painless with only occasional itching?"},
    {"id": "6", "question": "Is there only one lesion rather than many?"},
    {"id": "7", "question": "Does anyone in your family have a similar lesion?"},
    {"id": "8", "question": "Did it appear after skin irritation or injury?"},
    {"id": "9", "question": "Is it more common in women?"},
    {"id": "10", "question": "Did it first appear in adulthood?"}
  ],
  "vasc": [
    {"id": "1", "question": "Is the lesion red or blue with visible tiny blood vessels?"},
    {"id": "2", "question": "Does the color fade when pressed and return when released?"},
    {"id": "3", "question": "Are there multiple lesions appearing in clusters?"},
    {"id": "4", "question": "Did it appear on exposed areas like hands, face, or legs?"},
    {"id": "5", "question": "Does it look like a red dot and sometimes bleed or hurt?"},
    {"id": "6", "question": "Did it appear during pregnancy?"},
    {"id": "7", "question": "Did it appear in childhood?"},
    {"id": "8", "question": "Has it grown rapidly or changed recently?"},
    {"id": "9", "question": "Is it small with minor swelling or temporary bleeding?"},
    {"id": "10", "question": "Is the surface flat or slightly raised?"}
  ],
  "akiec": [
    {"id": "1", "question": "Is the lesion on sun-exposed areas?"},
    {"id": "2", "question": "Is the surface red and dry?"},
    {"id": "3", "question": "Has it slowly grown in size or shape?"},
    {"id": "4", "question": "Does it have scaling or crusty texture like dry skin flakes?"},
    {"id": "5", "question": "Is it larger than 1cm in size?"},
    {"id": "6", "question": "Did it appear on sensitive areas like lips, ears, or near the eyes?"},
    {"id": "7", "question": "Does it bleed when pressed or feel swollen?"},
    {"id": "8", "question": "Did it appear in mid-adulthood or later?"},
    {"id": "9", "question": "Have you felt pain or irritation in that area?"},
    {"id": "10", "question": "Is the shape or size irregular?"}
  ],
  "bcc": [
    {"id": "1", "question": "Did the lesion appear on sun-exposed areas like face, scalp, neck, or arms?"},
    {"id": "2", "question": "Is it pearly or shiny with a small, firm bump?"},
    {"id": "3", "question": "Does it have irregular edges and a sunken center?"},
    {"id": "4", "question": "Does it ooze or bleed from time to time?"},
    {"id": "5", "question": "Has it grown very slowly over months or years?"},
    {"id": "6", "question": "Is it white with unclear edges and a raised look?"},
    {"id": "7", "question": "Does it feel stuck to the skin and bleed when scratched?"},
    {"id": "8", "question": "Did it appear after age 50?"},
    {"id": "9", "question": "Is it spreading, especially on the face?"},
    {"id": "10", "question": "Does it hurt or feel sensitive and get damaged often?"}
  ],
};
