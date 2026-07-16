enum Priority {
  high, // sort weight 2
  medium, // sort weight 1 — default
  low, // sort weight 0
}

extension PriorityWeight on Priority {
  int get sortWeight {
    switch (this) {
      case Priority.high:
        return 2;
      case Priority.medium:
        return 1;
      case Priority.low:
        return 0;
    }
  }
}
