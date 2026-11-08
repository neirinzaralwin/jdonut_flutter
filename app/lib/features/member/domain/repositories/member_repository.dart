import 'package:jdonut/features/member/domain/entities/member.dart';

abstract interface class MemberRepository {
  /// Emits on every local change; `null` before seeding.
  Stream<Member?> watchMember();
}
