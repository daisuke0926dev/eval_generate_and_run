def instruction(input)
  require "ruby/openai"
  require 'json'
  require 'dotenv'

  weather_api = <<~HEREDOC
    リクエストパラメーター一覧
    JSON データをリクエストする際のベースとなる URL は以下になります。
    https://weather.tsukumijima.net/api/forecast
    この URL に下の表のパラメータを加え、実際にリクエストします。
    基本 URL + 久留米の ID (400040)
    例:https://weather.tsukumijima.net/api/forecast/city/400040
    
    パラメータ名	説明
    city	地域別に定義された ID 番号を表します。
    {
      "道北": {
        "稚内": "011000",
        "旭川": "012010",
        "留萌": "012020"
      },
      "道東": {
        "網走": "013010",
        "北見": "013020",
        "紋別": "013030",
        "根室": "014010",
        "釧路": "014020",
        "帯広": "014030"
      },
      "道南": {
        "室蘭": "015010",
        "浦河": "015020",
        "函館": "017010",
        "江差": "017020"
      },
      "道央": {
        "札幌": "016010",
        "岩見沢": "016020",
        "倶知安": "016030"
      },
      "青森県": {
        "青森": "020010",
        "むつ": "020020",
        "八戸": "020030"
      },
      "岩手県": {
        "盛岡": "030010",
        "宮古": "030020",
        "大船渡": "030030"
      },
      "宮城県": {
        "仙台": "040010",
        "白石": "040020"
      },
      "秋田県": {
        "秋田": "050010",
        "横手": "050020"
      },
      "山形県": {
        "山形": "060010",
        "米沢": "060020",
        "酒田": "060030",
        "新庄": "060040"
      },
      "福島県": {
        "福島": "070010",
        "小名浜": "070020",
        "若松": "070030"
      },
      "茨城県": {
        "水戸": "080010",
        "土浦": "080020"
      },
      "栃木県": {
        "宇都宮": "090010",
        "大田原": "090020"
      },
      "群馬県": {
        "前橋": "100010",
        "みなかみ": "100020"
      },
      "埼玉県": {
        "さいたま": "110010",
        "熊谷": "110020",
        "秩父": "110030"
      },
      "千葉県": {
        "千葉": "120010",
        "銚子": "120020",
        "館山": "120030"
      },
      "東京都": {
        "東京": "130010",
        "大島": "130020",
        "八丈島": "130030",
        "父島": "130040"
      },
      "神奈川県": {
        "横浜": "140010",
        "小田原": "140020"
      },
      "新潟県": {
        "新潟": "150010",
        "長岡": "150020",
        "高田": "150030",
        "相川": "150040"
      },
      "富山県": {
        "富山": "160010",
        "伏木": "160020"
      },
      "石川県": {
        "金沢": "170010",
        "輪島": "170020"
      },
      "福井県": {
        "福井": "180010",
        "敦賀": "180020"
      },
      "山梨県": {
        "甲府": "190010",
        "河口湖": "190020"
      },
      "長野県": {
        "長野": "200010",
        "松本": "200020",
        "飯田": "200030"
      },
      "岐阜県": {
        "岐阜": "210010",
        "高山": "210020"
      },
      "静岡県": {
        "静岡": "220010",
        "網代": "220020",
        "三島": "220030",
        "浜松": "220040"
      },
      "愛知県": {
        "名古屋": "230010",
        "豊橋": "230020"
      },
      "三重県": {
        "津": "240010",
        "尾鷲": "240020"
      },
      "滋賀県": {
        "大津": "250010",
        "彦根": "250020"
      },
      "京都府": {
        "京都": "260010",
        "舞鶴": "260020"
      },
      "大阪府": {
        "大阪": "270000"
      },
      "兵庫県": {
        "神戸": "280010",
        "豊岡": "280020"
      },
      "奈良県": {
        "奈良": "290010",
        "風屋": "290020"
      },
      "和歌山県": {
        "和歌山": "300010",
        "潮岬": "300020"
      },
      "鳥取県": {
        "鳥取": "310010",
        "米子": "310020"
      },
      "島根県": {
        "松江": "320010",
        "浜田": "320020",
        "西郷": "320030"
      },
      "岡山県": {
        "岡山": "330010",
        "津山": "330020"
      },
      "広島県": {
        "広島": "340010",
        "庄原": "340020"
      },
      "山口県": {
        "下関": "350010",
        "山口": "350020",
        "柳井": "350030",
        "萩": "350040"
      },
      "徳島県": {
        "徳島": "360010",
        "日和佐": "360020"
      },
      "香川県": {
        "高松": "370000"
      },
      "愛媛県": {
        "松山": "380010",
        "新居浜": "380020",
        "宇和島": "380030"
      },
      "高知県": {
        "高知": "390010",
        "室戸岬": "390020",
        "清水": "390030"
      },
      "福岡県": {
        "福岡": "400010",
        "八幡": "400020",
        "飯塚": "400030",
        "久留米": "400040"
      },
      "佐賀県": {
        "佐賀": "410010",
        "伊万里": "410020"
      },
      "長崎県": {
        "長崎": "420010",
        "佐世保": "420020",
        "厳原": "420030",
        "福江": "420040"
      },
      "熊本県": {
        "熊本": "430010",
        "阿蘇乙姫": "430020",
        "牛深": "430030",
        "人吉": "430040"
      },
      "大分県": {
        "大分": "440010",
        "中津": "440020",
        "日田": "440030",
        "佐伯": "440040"
      },
      "宮崎県": {
        "宮崎": "450010",
        "延岡": "450020",
        "都城": "450030",
        "高千穂": "450040"
      },
      "鹿児島県": {
        "鹿児島": "460010",
        "鹿屋": "460020",
        "種子島": "460030",
        "名瀬": "460040"
      },
      "沖縄県": {
        "那覇": "471010",
        "名護": "471020",
        "久米島": "471030",
        "南大東": "472000",
        "宮古島": "473000",
        "石垣島": "474010",
        "与那国島": "474020"
      }
    }
    ------------
    レスポンスフィールド
    {
      "publicTime": "ISO8601 format timestamp of weather overview publication",
      "publicTimeFormatted": "Formatted timestamp of weather overview publication",
      "headlineText": "Weather overview headline",
      "bodyText": "Text of weather overview",
      "text": "Complete weather overview",
      "forecasts": [
        {
          "date": "Forecast date",
          "dateLabel": "Label of forecast date (Today, Tomorrow, Day after tomorrow)",
          "telop": "Weather condition (e.g., Sunny, Cloudy, Rainy)",
          "detail": {
            "weather": "Detailed weather information",
            "wind": "Wind strength",
            "wave": "Wave height (only for coastal areas)"
          },
          "temperature": {
            "max": {
              "celsius": "Maximum temperature in Celsius",
              "fahrenheit": "Maximum temperature in Fahrenheit"
            },
            "min": {
              "celsius": "Minimum temperature in Celsius",
              "fahrenheit": "Minimum temperature in Fahrenheit"
            }
          },
          "chanceOfRain": {
            "T00_06": "Precipitation probability from 0 to 6 hours",
            "T06_12": "Precipitation probability from 6 to 12 hours",
            "T12_18": "Precipitation probability from 12 to 18 hours",
            "T18_24": "Precipitation probability from 18 to 24 hours"
          },
          "image": {
            "title": "Weather condition title",
            "url": "URL of weather icon (SVG image)",
            "width": "Width of weather icon",
            "height": "Height of weather icon"
          }
        }
      ],
      "location": {
        "area": "Regional name",
        "prefecture": "Prefecture name",
        "district": "Primary subdivision name",
        "city": "City name (meteorological observation station name)"
      },
      "copyright": {
        "title": "Copyright statement",
        "link": "URL of weather forecast API (compatible with livedoor weather)",
        "image": "Icon of weather forecast API (compatible with livedoor weather)",
        "provider": "Weather data provider for the API (Japan Meteorological Agency)"
      }
    }
    
    example:
    {
      "publicTime": "2023-11-14T17:00:00+09:00",
      "publicTimeFormatted": "2023/11/14 17:00:00",
      "publishingOffice": "福岡管区気象台",
      "title": "福岡県 久留米 の天気",
      "link": "https://www.jma.go.jp/bosai/forecast/#area_type=offices&area_code=400000",
      "description": {
          "publicTime": "2023-11-14T16:34:00+09:00",
          "publicTimeFormatted": "2023/11/14 16:34:00",
          "headlineText": "",
          "bodyText": "　福岡県は、気圧の谷や湿った空気の影響により曇りの所もありますが、高気圧に覆われておおむね晴れとなっています。\n\n　１４日は、はじめ高気圧に覆われておおむね晴れますが、気圧の谷や湿った空気の影響により次第に曇りとなり、夜遅くは雨や雷雨となる所があるでしょう。\n\n　１５日は、気圧の谷や湿った空気の影響により曇りで、はじめ雨や雷雨となる所がありますが、昼過ぎからは高気圧に覆われておおむね晴れとなるでしょう。\n\n＜天気変化等の留意点＞\n　特にありません。",
          "text": "　福岡県は、気圧の谷や湿った空気の影響により曇りの所もありますが、高気圧に覆われておおむね晴れとなっています。\n\n　１４日は、はじめ高気圧に覆われておおむね晴れますが、気圧の谷や湿った空気の影響により次第に曇りとなり、夜遅くは雨や雷雨となる所があるでしょう。\n\n　１５日は、気圧の谷や湿った空気の影響により曇りで、はじめ雨や雷雨となる所がありますが、昼過ぎからは高気圧に覆われておおむね晴れとなるでしょう。\n\n＜天気変化等の留意点＞\n　特にありません。"
      },
      "forecasts": [
          {
              "date": "2023-11-14",
              "dateLabel": "今日",
              "telop": "晴のち曇",
              "detail": {
                  "weather": "晴れ　夜　くもり",
                  "wind": "南西の風　後　南の風",
                  "wave": "０．５メートル"
              },
              "temperature": {
                  "min": {
                      "celsius": null,
                      "fahrenheit": null
                  },
                  "max": {
                      "celsius": null,
                      "fahrenheit": null
                  }
              },
              "chanceOfRain": {
                  "T00_06": "--%",
                  "T06_12": "--%",
                  "T12_18": "--%",
                  "T18_24": "10%"
              },
              "image": {
                  "title": "晴のち曇",
                  "url": "https://www.jma.go.jp/bosai/forecast/img/110.svg",
                  "width": 80,
                  "height": 60
              }
          },
          {
              "date": "2023-11-15",
              "dateLabel": "明日",
              "telop": "曇のち晴",
              "detail": {
                  "weather": "くもり　昼過ぎ　から　晴れ",
                  "wind": "北の風",
                  "wave": "０．５メートル"
              },
              "temperature": {
                  "min": {
                      "celsius": "7",
                      "fahrenheit": "44.6"
                  },
                  "max": {
                      "celsius": "18",
                      "fahrenheit": "64.4"
                  }
              },
              "chanceOfRain": {
                  "T00_06": "10%",
                  "T06_12": "0%",
                  "T12_18": "0%",
                  "T18_24": "0%"
              },
              "image": {
                  "title": "曇のち晴",
                  "url": "https://www.jma.go.jp/bosai/forecast/img/210.svg",
                  "width": 80,
                  "height": 60
              }
          },
          {
              "date": "2023-11-16",
              "dateLabel": "明後日",
              "telop": "曇のち雨",
              "detail": {
                  "weather": "くもり　後　雨",
                  "wind": "北東の風　後　北西の風",
                  "wave": "０．５メートル　後　１メートル"
              },
              "temperature": {
                  "min": {
                      "celsius": "10",
                      "fahrenheit": "50"
                  },
                  "max": {
                      "celsius": "18",
                      "fahrenheit": "64.4"
                  }
              },
              "chanceOfRain": {
                  "T00_06": "80%",
                  "T06_12": "80%",
                  "T12_18": "80%",
                  "T18_24": "80%"
              },
              "image": {
                  "title": "曇のち雨",
                  "url": "https://www.jma.go.jp/bosai/forecast/img/212.svg",
                  "width": 80,
                  "height": 60
              }
          }
      ],
      "location": {
          "area": "九州",
          "prefecture": "福岡県",
          "district": "筑後地方",
          "city": "久留米"
      },
      "copyright": {
          "title": "(C) 天気予報 API（livedoor 天気互換）",
          "link": "https://weather.tsukumijima.net/",
          "image": {
              "title": "天気予報 API（livedoor 天気互換）",
              "link": "https://weather.tsukumijima.net/",
              "url": "https://weather.tsukumijima.net/logo.png",
              "width": 120,
              "height": 120
          },
          "provider": [
              {
                  "link": "https://www.jma.go.jp/jma/",
                  "name": "気象庁 Japan Meteorological Agency",
                  "note": "気象庁 HP にて配信されている天気予報を JSON データへ編集しています。"
              }
          ]
      }
  }
  HEREDOC

  instructions = <<~HEREDOC
  命令:
  以下を満たすjsonデータを250tokens以内で返してください。jsonデータの最初と最後に★をつけてください。
  制約:
  回答はevalで実行できるRubyコードのString。(この会話において自然言語は不要)
  提示されたコードをそのまま利用できない場合、理由と私の次行う作業を明示してください。
  JSON:
  [eval_code:evalで実行できるコードで、最後に標準出力で会話形式の回答を出力すること。
  need_info:[key:実行するのに必要な情報(APIキーなど), info:その説明]
  ]
  参考:
  HEREDOC
  Dotenv.load
  question = "質問:" + input
  prompt = question + instructions + weather_api
  client = OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])
  # print("chat_start:")
  response = client.chat(
    parameters: {
      model: "gpt-4-1106-preview",
      messages: [
        {"role": "system", "content": "あなたはRubyプログラマーです。"},
        {"role": "user", "content": prompt }
      ],
      response_format:{"type":"json_object"},
      max_tokens: 300,
    },
  )
  response['choices'].first['message']['content']
  
  # response変数は既に定義されていると仮定
  response_content = response['choices'][0]['message']['content']
  # puts "chat_end:"+ response_content
  # puts 
  response_content = response_content.match(/★(.*)★/) ? response_content.match(/★(.*)★/)[1] : response_content
  # puts "response before JSON decode: #{response_content}"
  # puts 
  response_content = JSON.parse(response_content)
  
  # RubyのJSONライブラリは、デフォルトで数値を適切に扱います（Pythonのdecimal_to_intのような関数は不要）
  # puts "Received response: #{JSON.generate(response_content)}"
  # puts 
  
  # プロトタイプなのでコメントアウト
  # if need_info = response_content["need_info"] {
    #   # ユーザーに入力してもらう
    #   # 再度質問(context保持(threads?))
    # }
    # print("run_eval:" + response_content["eval_code"])
    # puts 
    # puts 
    # puts 
  eval(response_content["eval_code"])
end


puts "-----start-----"
puts instruction(gets)
puts "-----end-----"