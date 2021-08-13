import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'https://demo.degpegserver.degpeg.com';

Future<dynamic> login(String email, String password) async {
  try {
    var response = await http.post(Uri.parse('$_baseUrl/users/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}));
    var response2 = await http.get(
      Uri.parse(
          '$_baseUrl/users?filter={"where":{"email":"$email"},"include":[{"relation":"userPlan"}]}'),
      headers: {"Content-Type": "application/json"},
    );

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
    print(e);
  }

  // print(jsonDecode(response.body));
}

Future<dynamic> createSession(roleId, data) async {
  try {
    var response = await http.post(
        Uri.parse('$_baseUrl/influencers/$roleId/live-sessions'),
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
        Uri.parse('$_baseUrl/live-sessions/$sessionId/session-data'),
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

Future<dynamic> editSession(sessionId, data) async {
  try {
    var response = await http.patch(
        Uri.parse('$_baseUrl/live-sessions/${sessionId}'),
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

Future<dynamic> createChannel(roleId, data) async {
  try {
    var response = await http.post(
        Uri.parse('$_baseUrl/influencers/$roleId/channels'),
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

Future<dynamic> getUserChannels({required String roleId}) async {
  http.Response response;
  try {
    response = await http.get(
      Uri.parse('$_baseUrl/influencers/$roleId/channels'),
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

Future<dynamic> getCategories() async {
  http.Response response;
  try {
    response = await http.get(
      Uri.parse('$_baseUrl/live-session-categories'),
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

Future<dynamic> getAllSessions({required String userId}) async {
  http.Response response;
  try {
    response = await http.get(
      Uri.parse(
          '$_baseUrl/influencers/$userId/live-sessions?filter={"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
      headers: {"Content-Type": "application/json"},
    );
    if ((response.statusCode >= 200 && response.statusCode < 300)) {
      // print(jsonDecode(response.body));
      // print(response.body);
      // print('response.body');

      return response.body;
    } else {
      print('StatusCode:${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print(e);
  }
}

Future<dynamic> getLiveSessions({userId = '60df1194b25972238c3e1945'}) async {
  try {
    var response = await http.get(
      Uri.parse(
          '$_baseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"live"}}'),
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

Future<dynamic> getUpcomingSessions({@required userId}) async {
  try {
    var response = await http.get(
      Uri.parse(
          '$_baseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"planned"},"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
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

Future<dynamic> getPastSessions({@required userId}) async {
  try {
    var response = await http.get(
      Uri.parse(
          '$_baseUrl/influencers/$userId/live-sessions?filter={"where":{"status":"completed"},"include":[{"relation":"sessionData"},{"relation":"liveSessionCategory"},{"relation":"promotions"}]}'),
      headers: {"Content-Type": "application/json"},
    );
    if ((response.statusCode >= 200 && response.statusCode < 300)) {
      print(jsonDecode(response.body));
      return response.body;
    } else {
      print('StatusCode:${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print(e);
  }
}

Future<dynamic> getSessionDetails(
    {sessionId = '60e2eee8b25972238c3e1950'}) async {
  try {
    var response = await http.get(
      Uri.parse('$_baseUrl/live-sessions/$sessionId'),
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

Future<dynamic> getCtaData({@required ctaId}) async {
  try {
    var response = await http.get(
      Uri.parse('$_baseUrl/user-ctas?filter={"where":{"id":"$ctaId"}}'),
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

Future<dynamic> getChannelData({@required channelId}) async {
  try {
    var response = await http.get(
      Uri.parse('$_baseUrl/channels/$channelId'),
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

generateStreamKey() {
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
