/// The service writer who handed out the job.
///
/// A row rather than a typed name, so that months of history group under one
/// person even after somebody types their name differently.
library;

class Writer {
  Writer({required this.id, required this.name});

  final int id;
  final String name;
}
