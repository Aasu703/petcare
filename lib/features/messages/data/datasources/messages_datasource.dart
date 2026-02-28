import 'package:petcare/features/messages/data/models/message_model.dart';

abstract interface class IMessageRemoteDataSource {
  Future<List<MessageModel>> getAllMessages({int page, int limit});
  Future<List<MessageModel>> getMyMessages();
  Future<MessageModel> createMessage(String content);
  Future<MessageModel?> getMessageById(String messageId);
  Future<MessageModel> updateMessage(String messageId, String content);
  Future<bool> deleteMessage(String messageId);
}
