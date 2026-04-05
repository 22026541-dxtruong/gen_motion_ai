import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job_stream.dto.dart';

class JobEventsClient {
  const JobEventsClient();

  Stream<JobStreamEventDto> streamJobEvents({
    required String jobId,
    required String accessToken,
  }) async* {
    final client = HttpClient();
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.jobEvents(jobId)}');
    HttpClientResponse? response;

    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to open SSE: ${response.statusCode}',
          uri: uri,
        );
      }

      String? currentEventType;
      final dataLines = <String>[];

      await for (final line in response.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.isEmpty) {
          if (currentEventType != null && dataLines.isNotEmpty) {
            final payload = jsonDecode(dataLines.join('\n')) as Map<String, dynamic>;
            yield JobStreamEventDto.fromSse(currentEventType, payload);
          }
          currentEventType = null;
          dataLines.clear();
          continue;
        }

        if (line.startsWith('event:')) {
          currentEventType = line.substring(6).trim();
          continue;
        }

        if (line.startsWith('data:')) {
          dataLines.add(line.substring(5).trim());
        }
      }
    } finally {
      response?.detachSocket().then((socket) => socket.destroy()).catchError((_) {});
      client.close(force: true);
    }
  }
}
