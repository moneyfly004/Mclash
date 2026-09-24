import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/http_utils.dart';

/// 回归：订阅地址里的 `token=` 就是账号凭证。
///
/// 真机 app.log 里出现过完整的
/// `已在添加账号订阅 (https://sub.dollarsfly.top/api/v1/client/subscribe?token=9c68ff44…)`，
/// 而日志页支持一键复制到剪贴板（然后被粘贴到群里）= 账号送人。
/// 所以所有打印 / 复制 URL 的地方都必须先过 [HttpUtils.redact]。
void main() {
  group('HttpUtils.redact', () {
    test('?token=abc&x=1：只打码 token，其它参数原样保留', () {
      expect(
        HttpUtils.redact(
          'https://sub.example.com/api/v1/client/subscribe?token=abc&x=1',
        ),
        'https://sub.example.com/api/v1/client/subscribe?token=***&x=1',
      );
    });

    test('真机那条订阅地址：token 值整段消失', () {
      const url =
          'https://sub.dollarsfly.top/api/v1/client/subscribe?token=9c68ff44deadbeef&flag=clash';
      final out = HttpUtils.redact(url);
      expect(out, contains('token=***'));
      expect(out, isNot(contains('9c68ff44')));
      expect(out, contains('flag=clash'), reason: '不敏感的参数要留着，方便排查');
    });

    test('&access_token= 这类带前缀的键也要打码（以前只认 token=）', () {
      expect(
        HttpUtils.redact(
          'https://api.example.com/v1/me?lang=zh&access_token=abcdef012345&page=2',
        ),
        'https://api.example.com/v1/me?lang=zh&access_token=***&page=2',
      );
      expect(
        HttpUtils.redact('https://api.example.com/v1/me?refresh_token=xyz'),
        'https://api.example.com/v1/me?refresh_token=***',
      );
      expect(
        HttpUtils.redact('https://api.example.com/v1/sign?sign=deadbeef&t=1'),
        'https://api.example.com/v1/sign?sign=***&t=1',
      );
    });

    test('没有 query：原样返回（不要动 path）', () {
      const url = 'https://sub.example.com/api/v1/client/subscribe';
      expect(HttpUtils.redact(url), url);
      expect(HttpUtils.redact('https://example.com/'), 'https://example.com/');
    });

    test('大小写混合的参数名同样打码', () {
      expect(
        HttpUtils.redact('https://a.example.com/s?X=1&ToKeN=abc'),
        'https://a.example.com/s?X=1&ToKeN=***',
      );
      expect(
        HttpUtils.redact('https://a.example.com/s?Access_Token=abc&k=v'),
        'https://a.example.com/s?Access_Token=***&k=v',
      );
    });

    test('token 出现在 path 里：保留原样（那是路径，不是凭证值）', () {
      const url =
          'https://sub.example.com/api/v1/client/subscribe/token/9c68ff44';
      expect(HttpUtils.redact(url), url);
      const url2 = 'https://sub.example.com/token=9c68ff44';
      expect(HttpUtils.redact(url2), url2);
    });

    test('非法 / 畸形输入不抛异常，且仍然打码能识别的 token', () {
      for (final input in <String>[
        '',
        '?',
        '??token=',
        'token=abc',
        'http://a b?token=abc',
        'http://[::1?token=x',
        '%%%?token=abc&k=1',
        'a=1&token=%E4%B8%AD%E6%96%87',
      ]) {
        expect(() => HttpUtils.redact(input), returnsNormally, reason: input);
      }
      expect(HttpUtils.redact('http://a b?token=abc'), 'http://a b?token=***');
      expect(HttpUtils.redact('token=abc'), 'token=***');
      expect(HttpUtils.redact('??token='), '??token=***');
      expect(HttpUtils.redact('%%%?token=abc&k=1'), '%%%?token=***&k=1');
      expect(
        HttpUtils.redact('a=1&token=%E4%B8%AD%E6%96%87'),
        'a=1&token=***',
      );
    });

    test('片段（#）里的参数也要打码', () {
      expect(
        HttpUtils.redact('https://a.example.com/s?token=abc#/dash?token=def'),
        'https://a.example.com/s?token=***#/dash?token=***',
      );
    });

    test('深链里嵌套的（已转义的）订阅地址也要打码', () {
      final out = HttpUtils.redact(
        'clash://install-config?url=https%3A%2F%2Fsub.example.com%2Fapi%2Fv1'
        '%2Fclient%2Fsubscribe%3Ftoken%3D9c68ff44deadbeef%26flag%3Dclash',
      );
      expect(out, isNot(contains('9c68ff44')));
      expect(out, contains('token%3D***'));
    });

    test('重复调用是幂等的（打码后的串再打码结果不变）', () {
      const url = 'https://sub.example.com/s?token=abc&x=1';
      final once = HttpUtils.redact(url);
      expect(HttpUtils.redact(once), once);
    });

    test('没有等号的裸 token 不误判（避免把整段 path 打掉）', () {
      const url = 'https://sub.example.com/sub/token-abc/x?k=v';
      expect(HttpUtils.redact(url), url);
    });
  });
}
