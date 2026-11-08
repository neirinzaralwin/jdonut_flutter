import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/member/data/repositories/member_repository_impl.dart';
import 'package:jdonut/features/member/domain/entities/member.dart';
import 'package:jdonut/features/member/domain/repositories/member_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_providers.g.dart';

@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) =>
    MemberRepositoryImpl(ref.watch(appDatabaseProvider));

/// Shared by Home and Rewards — one record for every screen.
@Riverpod(keepAlive: true)
Stream<Member?> member(Ref ref) =>
    ref.watch(memberRepositoryProvider).watchMember();
