import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/clash_traffic_watcher.dart';

void main() {
  group('内核流量推送解析', () {
    test('多行 JSON：取最后一条（这正是旧实现解析失败、流量永远 0 的场景）', () {
      const payload = '{"up":1,"down":2,"upTotal":10,"downTotal":20}\n'
          '{"up":3,"down":4,"upTotal":30,"downTotal":40}\n'
          '{"up":5,"down":6,"upTotal":50,"downTotal":60}';
      final got = ClashTrafficWatcher.parseTrafficPayload(payload);
      expect(got, isNotNull);
      expect(got!['up'], 5);
      expect(got['down'], 6);
      expect(got['upTotal'], 50);
      expect(got['downTotal'], 60);
    });

    test('单条 JSON 正常解析', () {
      final got = ClashTrafficWatcher.parseTrafficPayload(
        '{"up":100,"down":200,"upTotal":1000,"downTotal":2000}',
      );
      expect(got!['up'], 100);
    });

    test('夹带半行/坏数据也不影响（不能因为一行坏就整条流断掉）', () {
      const payload = '{"up":7,"down":8}\n'
          '{"up":9,"do'; 
      final got = ClashTrafficWatcher.parseTrafficPayload(payload);
      expect(got!['up'], 7);
      expect(got['down'], 8);
    });

    test('空内容/非 JSON（错误提示等）返回 null，不抛异常', () {
      expect(ClashTrafficWatcher.parseTrafficPayload(''), isNull);
      expect(ClashTrafficWatcher.parseTrafficPayload('   '), isNull);
      expect(
        ClashTrafficWatcher.parseTrafficPayload('Unauthorized'),
        isNull,
        reason: '控制密钥不对时内核返回的是文本，不能当成流量数据',
      );
    });

    test('缺字段时按 0 处理（不崩、也不显示上一次的旧值给别人看）', () {
      final got = ClashTrafficWatcher.parseTrafficPayload('{"up":12}');
      expect(got!['up'], 12);
      expect(got['down'], isNull);
    });
  });
}
