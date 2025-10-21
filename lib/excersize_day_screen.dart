import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';

class AddExerciseScreen extends StatefulWidget {
  final String day;
  const AddExerciseScreen({super.key, required this.day});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.day} Exercises"),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text input
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Exercise Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ), // better spacing inside
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Provider.of<ExerciseProvider>(context, listen: false)
                        .addExerciseToDay(widget.day, value,3,DateTime.now());
                    _controller.clear();
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please enter an exercise name!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Add button
              ElevatedButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    Provider.of<ExerciseProvider>(context, listen: false)
                        .addExerciseToDay(widget.day, text,3,DateTime.now());
                    _controller.clear();
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please enter an exercise name!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.black,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[300],
                ),
                child: const Icon(Icons.add,size: 30,),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Consumer<ExerciseProvider>(
                  builder: (context, provider, _) {
                    final exercises = provider.getExercisesForDay(widget.day);

                    if (exercises.isEmpty) {
                      return const Center(
                        child: Text("No exercises added yet\n please enter exercise ",
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                      );
                    }

                    return ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical:8,horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(11),
                          ),

                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[300],
                              child: Text("${index + 1}"),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(exercises[index].name),


                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



