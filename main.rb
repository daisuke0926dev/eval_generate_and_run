def instruction(input)
  require "ruby/openai"
  require 'json'
  require 'dotenv'

  weather_api = <<~HEREDOC
    リクエストパラメーター一覧
    本APIは、GETメソッドのみサポートしています。
    URL例...https://map.yahooapis.jp/weather/V1/place?coordinates=latitude,longitude&appid=appid

    パラメーター            値         説明
    appid（必須）           string     Client ID（アプリケーションID）。詳細はこちらをご覧ください。
    coordinates（必須）     string     緯度経度です。経度・緯度の順番で、コンマ区切りで指定してください。
                                      世界測地系で指定してください。
                                      緯度経度を複数指定する場合は、半角スペースで区切ってください（最大10）。
    output                  string     出力形式です。
                                      xml - XML形式（デフォルト）
                                      json - JSON形式
    callback                string     JSONPとして出力する際のコールバック関数名を入力するためのパラメーター。UTF-8でエンコードした文字列を指定してください。
    date                    string     日時を指定します（YYYYMMDDHHMI形式）。現在から2時間前までの日時を指定できます。
    past                    integer    過去の降水強度実測値を取得する場合に指定できます。
                                      0 - 取得しない（デフォルト）
                                      1 - 1時間前までの降水強度実測値を取得する
                                      2 - 2時間前までの降水強度実測値を取得する
    interval                integer    取得間隔を指定してください。
                                      10 - 10分毎（デフォルト）
                                      5 - 5分毎
    ------------
    レスポンスフィールド
      フィールド        説明
      YDF              クエリーレスポンスのすべてを含みます。
        ResultInfo     レスポンスのまとめ情報です。
          Count        レスポンスに含まれるデータ件数です。
          Total        全データ件数です。
          Start        全データからの取得開始位置です。
          Status       リクエストに処理結果を伝えるためのコードです。正常終了の場合、200を出力します。エラーの場合は、下記エラー項目を参照してください。
          Latency      レスポンスを生成するのに要した時間です。
          Description  データの説明です。詳細情報がある場合に表示されます。
        Feature        検索結果1件分のデータです。
          Id           データの識別子です。
          Name         データの名称です。
          Geometry     拠点の場所を表すGeometry要素です（世界測地系）。
            Type       図形種別です。
            Coordinates座標情報です。
          Property     地点の詳細情報です。
            WeatherAreaCode 一次細分コード（4桁）です。
            WeatherList     気象情報リストです（実測値および予測値）。
              Weather       気象情報です。
                Type        気象情報の区分です。
                            observation - 実測値
                            forecast - 予測値
                Date        日付と時刻です（YYYYMMDDHHMI形式）。
                Rainfall    降水強度です（単位:mm/h）。小数点第二位までの精度です。
                            ※降水強度は、気象レーダーで観測された降水の強さを時間雨量（mm/h）に換算した値で、実際の雨量とは異なります。
  HEREDOC

  instructions = <<~HEREDOC
  命令:
  以下を満たすjsonデータを250tokens以内で返してください。jsonデータの最初と最後に★をつけてください。
  制約:
  回答はevalで実行できるRubyコードのString。(この会話において自然言語は不要)
  提示されたコードをそのまま利用できない場合、理由と私の次行う作業を明示してください。
  JSON:
  [eval_code:evalで実行できるコード
  need_info:[key:実行するのに必要な情報(APIキーなど), info:その説明]
  ]
  参考:
  HEREDOC
  Dotenv.load
  question = "質問:" + input
  prompt = question + instructions + weather_api
  client = OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])
  print("chat_start:")
  response = client.chat(
    parameters: {
      model: "gpt-4-1106-preview",
      messages: [
        {"role": "system", "content": "あなたはRubyプログラマーです"},
        {"role": "user", "content": prompt + " YAHOO_APPIDはこれです:" + ENV['YAHOO_APPID']} # appidの記述はプロトタイプゆえ。
      ],
      response_format:{"type":"json_object"},
      max_tokens: 300,
    },
  )
  response['choices'].first['message']['content']
  
  # response変数は既に定義されていると仮定
  response_content = response['choices'][0]['message']['content']
  puts "chat_end:"+ response_content
  puts 
  response_content = response_content.match(/★(.*)★/) ? response_content.match(/★(.*)★/)[1] : response_content
  puts "response before JSON decode: #{response_content}"
  puts 
  response_content = JSON.parse(response_content)
  
  # RubyのJSONライブラリは、デフォルトで数値を適切に扱います（Pythonのdecimal_to_intのような関数は不要）
  puts "Received response: #{JSON.generate(response_content)}"
  puts 
  
  # プロトタイプなのでコメントアウト
  # if need_info = response_content["need_info"] {
    #   # ユーザーに入力してもらう
    #   # 再度質問(context保持(threads?))
    # }
    print("run_eval:" + response_content["eval_code"])
    puts 
  eval(response_content["eval_code"])
end


puts "-----start-----"
puts instruction(gets)
puts "-----end-----"