/// Repository操作で発生するエラー
sealed class RepositoryError implements Exception {
  const RepositoryError();
}

/// 指定したIDのエンティティが存在しない
class NotFoundError extends RepositoryError {
  final String id;
  const NotFoundError(this.id);

  @override
  String toString() => 'NotFoundError: id=$id';
}

/// DB操作に失敗した
class SaveFailedError extends RepositoryError {
  final Object cause;
  const SaveFailedError(this.cause);

  @override
  String toString() => 'SaveFailedError: $cause';
}
