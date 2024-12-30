import 'package:flutter/material.dart';
import 'package:furcare/models/event.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/models/pet.dart';

class EventListTile extends StatefulWidget {
  EventListTile({
    super.key,
    required this.event,
    required this.showEditDialog,
  });

  Map<String, dynamic> event;
  final Function(Event) showEditDialog;

  @override
  State<EventListTile> createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showEventDetails(context),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade800,
            child: const Icon(Icons.event, color: Colors.white),
          ),
          title: Text(
            widget.event[Dbhelper.eventTitle],
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            widget.event[Dbhelper.eventsDate],
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              widget.showEditDialog(
                Event(
                  id: widget.event[Dbhelper.eventId],
                  title: widget.event[Dbhelper.eventTitle],
                  dateTime: widget.event[Dbhelper.eventsDate],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void showEventDetails(BuildContext context) async {
    final petId = widget.event[Dbhelper.eventPetId];
    final petName = await Dbhelper.fetchPetNameById(petId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.event[Dbhelper.eventTitle],
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Checkbox(
                    value: widget.event[Dbhelper.isDone] == 1,
                    onChanged: (v) {
                      setState(() {
                        Map<String, dynamic> updatedEvent =
                            Map.from(widget.event);
                        updatedEvent[Dbhelper.isDone] = v! ? 1 : 0;

                        Dbhelper.updateEventStatus(
                          widget.event[Dbhelper.eventId],
                          updatedEvent[Dbhelper.isDone],
                        );

                        widget.event = updatedEvent;
                      });

                      Navigator.pop(context);
                      showEventDetails(context);
                    },
                  ),
                ],
              ),
              Divider(color: Colors.deepPurple.shade100),
              const SizedBox(height: 8),
              Text(
                'Date & Time: ${widget.event[Dbhelper.eventsDate]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                petName?.isNotEmpty == true ? 'Pet: $petName' : '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
