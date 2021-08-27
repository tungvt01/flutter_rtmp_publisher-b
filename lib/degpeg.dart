import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DegpegServices {
  static const String _devBaseUrl = 'https://api.dev.degpeg.com';
  static const String _baseUrl = 'https://demo.degpegserver.degpeg.com';

  static Future<dynamic> login(String email, String password) async {
    try {
      var response = await http.post(Uri.parse('$_devBaseUrl/users/login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}));
      log('1');
      var response2 = await http.get(
        Uri.parse(
            '$_devBaseUrl/users?filter={"where":{"email":"$email"},"include":[{"relation":"userPlan"}]}'),
        headers: {"Content-Type": "application/json"},
      );
      log('2');

      if ((response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response2.statusCode >= 200 &&
          response2.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return {
          "token": jsonDecode(response.body)['token'],
          "userData": jsonDecode(response2.body)[0]
        };
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
        return jsonDecode(response.body);
      }
    } catch (e) {
      log('xxxxxxxx___0_____xxxxxxxxx');
      rethrow;
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> createSession(roleId, data) async {
    try {
      var response = await http.post(
          Uri.parse('$_devBaseUrl/influencers/$roleId/live-sessions'),
          headers: {"Content-Type": "application/json"},
          body: data);
      var sessionId = jsonDecode(response.body)["id"];
      var sessionData = {
        "views_count": "0",
        "like_counts": "0",
        "share_count": "0",
        "comments_count": "0",
        "view_info_count": "0",
        "liveSessionId": sessionId
      };
      var response2 = await http.post(
          Uri.parse('$_devBaseUrl/live-sessions/$sessionId/session-data'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(sessionData));

      if ((response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response2.statusCode >= 200 &&
          response2.statusCode < 300)) {
        print(jsonDecode(response.body));
        print(jsonDecode(response2.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> editSession(sessionId, data) async {
    try {
      var response = await http.patch(
          Uri.parse('$_devBaseUrl/live-sessions/${sessionId}'),
          headers: {"Content-Type": "application/json"},
          body: data);

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> createChannel(roleId, data) async {
    try {
      var response = await http.post(
          Uri.parse('$_devBaseUrl/influencers/$roleId/channels'),
          headers: {"Content-Type": "application/json"},
          body: data);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> updateStreamKeyInChannel(
      {required String roleId,
      required String channelId,
      required String streamKey}) async {
    try {
      var response = await http.patch(
          Uri.parse('$_devBaseUrl/influencers/$roleId/channels'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"id": channelId, "streamingKey": streamKey}));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> getUserChannels({required String roleId}) async {
    http.Response response;
    try {
      response = await http.get(
        Uri.parse('$_devBaseUrl/influencers/$roleId/channels'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getChannelTemplates() async {
    http.Response response;
    try {
      response = await http.get(
        Uri.parse('$_devBaseUrl/channel-templates'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getCategories() async {
    http.Response response;
    try {
      response = await http.get(
        Uri.parse('$_devBaseUrl/live-session-categories'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getAllSessions({required String userId}) async {
    http.Response response;
    // try {
    response = await http.get(
      Uri.parse(
          '$_devBaseUrl/influencers/$userId/live-sessions?filter={"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
      headers: {"Content-Type": "application/json"},
    );
    if ((response.statusCode >= 200 && response.statusCode < 300)) {
      // print(jsonDecode(response.body));
      // print(response.body);
      // print('response.body');
      // log('pilpilpil');

      return response.body;
    } else {
      log('pilpilpil');

      print('StatusCode:${response.statusCode}');
      print(response.body);
      throw Exception('Something went wrong!');
    }
    // } catch (e) {
    //   print(e);
    // }
  }

  static Future<dynamic> getLiveSessions(
      {userId = '60df1194b25972238c3e1945'}) async {
    try {
      var response = await http.get(
        Uri.parse(
            '$_devBaseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"live"}}'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return jsonDecode(response.body);
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getUpcomingSessions({@required userId}) async {
    try {
      var response = await http.get(
        Uri.parse(
            '$_devBaseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"planned"},"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(response.body);
        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getPastSessions({@required userId}) async {
    try {
      var response = await http.get(
        Uri.parse(
            '$_devBaseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"completed"},"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // log(jsonDecode(response.body).toString());
        // log('::::');

        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // log('::::');
      print(e);
    }
  }

  static Future<dynamic> getSessionDetails(
      {sessionId = '60e2eee8b25972238c3e1950'}) async {
    try {
      var response = await http.get(
        Uri.parse('$_devBaseUrl/live-sessions/$sessionId'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(jsonDecode(response.body));
        return jsonDecode(response.body);
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getCtaData({@required ctaId}) async {
    try {
      var response = await http.get(
        Uri.parse('$_devBaseUrl/user-ctas?filter={"where":{"id":"$ctaId"}}'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(response.body);
        return jsonDecode(response.body);
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getChannelData({@required channelId}) async {
    try {
      var response = await http.get(
        Uri.parse('$_devBaseUrl/channels/$channelId'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(response.body);
        return jsonDecode(response.body);
      } else {
        return null;
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static generateStreamKey() {
    List randArr = LinkedHashSet<String>.from(
            DateTime.now().millisecondsSinceEpoch.toRadixString(36).split(''))
        .toList();

    if (randArr.length < 6) {
      print('r');
      generateStreamKey();
    }
    String randStr = randArr.join('').substring(0, 6);
    return randStr;
  }

  static Future<dynamic> getYoutubeStreamKey({@required userId}) async {
    try {
      var response = await http.get(
        Uri.parse('$_devBaseUrl/youtube-get-stream-key/$userId'),
        headers: {"Content-Type": "application/json"},
      );
      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // print(response.body);
        return response.body;
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> addYoutubeAccessToken(
      {required String id, required String accessToken}) async {
    try {
      var response = await http.post(
        Uri.parse('$_devBaseUrl/youtube-update-token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {"userId": id, "youtubeToken": accessToken},
        ),
      );

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> createYoutubeBroadcast(
      {required id, required String title, required String startTime}) async {
    try {
      var response = await http.post(
          Uri.parse('$_devBaseUrl/youtube-create-session/$id'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"sessionTitle": title, "stTime": startTime}));

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // log('///////////////////////////////');
        // print(response.body);

        return (jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> createYoutubeBinding(
      {required String id,
      required String streamId,
      required String broadcastId}) async {
    try {
      var response = await http.post(
          Uri.parse('$_devBaseUrl/youtube-bind-session-and-stream/$id'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"broadcastId": broadcastId, "streamId": streamId}));

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> addFacebookAccessToken({
    required String id,
    required String accessToken,
    required String expiry,
    required String fbUserId,
  }) async {
    try {
      var response = await http.post(
        Uri.parse('$_devBaseUrl/facebook-update-token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            "userId": id,
            "accessToken": accessToken,
            "expiresIn": expiry,
            "fbUserId": fbUserId
          },
        ),
      );

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        print(jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }

    // print(jsonDecode(response.body));
  }

  static Future<dynamic> createFacebookLiveSession(
      {required id,
      required String title,
      required String startTime,
      required String description}) async {
    try {
      var response = await http.post(
          Uri.parse('$_devBaseUrl/facebook-schedule-session/$id'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "stTime": startTime,
            "sessionTitle": title,
            "sessionDesc": description
          }));

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        // log('///////////////////////////////');
        print(response.body);

        return (jsonDecode(response.body));
      } else {
        print('StatusCode:${response.statusCode}');
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }
}
