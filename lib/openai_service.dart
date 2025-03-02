import 'dart:convert';

import 'package:alfred_4/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages=[];
  Future<String> isArtPromptAPI(String prompt) async {
    try{
      final res= await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": [
            {
              "role": "user",
              "content": "Does this message wants to generate as AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.",
            },
          ],
        }),
      );
      print(res.body);
      if(res.statusCode==200){
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content= content.trim();

        switch(content){
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
          case 'YES':
            final res= await dallEAPI(prompt);
            return res;
          default:
            final res= await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'I am unable to generate a response for you presently, as the A.P.I. from which I collect the data is not free anymore and I can not afford to pay for it presently. Sorry for the inconvenience caused. Thankyou!';
    }catch(e){
      return e.toString();
    }

  }
  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try{
      final res= await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": messages,
        }),
      );

      if(res.statusCode==200){
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content= content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'I am unable to generate a response for you as the API from which I collect the data is not free anymore and I can not afford to pay for it presently. Sorry for the inconvenience caused. Arigato!';
    }catch(e){
      return e.toString();
    }
  }
  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try{
      final res= await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n':1,
        }),
      );

      if(res.statusCode==200){
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl= imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'I am unable to generate a response for you as the API from which I collect the data is not free anymore and I can not afford to pay for it presently. Sorry for the inconvenience caused. Arigato!' ;
    }catch(e){
      return e.toString();
    }
  }
}