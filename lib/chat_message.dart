class Message {
  final String message,date,to, from;
  final bool isRemote;
  final int type;

  Message.fromJson(Map<String, dynamic> arguments)
      : message = arguments['message'],
        from = arguments['from'],
        to = arguments['to'],
        date = arguments['dttm'],
        type = arguments['messageType'],
        isRemote=true;

  Message({required this.type,required this.from,required this.message,required this.date,required this.to,this.isRemote=false});

  toJson() =>
      {"message": message, "to": to, "from": from, "dttm": date, "messageType": type};
}
