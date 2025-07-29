# Training Program Builder Documentation

## Overview
The Training Program Builder is a comprehensive web application that allows business users to create detailed, structured workout programs through a step-by-step wizard interface. The application integrates with Firebase Firestore to save programs and can be easily embedded into existing web applications as a modal component.

## Features

### 📋 Program Creation Wizard
- **6-Step Process**: Guided creation through logical steps
- **Progress Tracking**: Visual progress bar and step indicators
- **Validation**: Real-time validation at each step
- **Responsive Design**: Works on desktop and mobile devices

### 🏋️ Exercise Management
- **Comprehensive Database**: Pre-loaded with exercises categorized by body parts
- **Flexible Configuration**: Support for reps, duration, sets, rest periods
- **Multiple Training Styles**: Standard gym, metabolic circuit, AMRAP, time-based, hybrid
- **Custom Notes**: Add specific instructions for each exercise

### 💾 Firebase Integration
- **Firestore Storage**: Programs saved to `trainingPrograms` collection
- **User Authentication**: Links programs to authenticated users
- **Exercise Database**: Optional loading from Firestore `exercises` collection
- **Real-time Updates**: Automatic timestamping and versioning

## Implementation Guide

### 1. Integration with Existing Application

#### HTML Integration
Add the following to your main application:

```html
<!-- Include the Training Program Builder -->
<link rel="stylesheet" href="TrainingProgramBuilder.html">
<script src="TrainingProgramBuilder.html"></script>

<!-- Trigger Button (customize as needed) -->
<button onclick="openTrainingBuilder()">Create Training Program</button>
```

#### Modal Integration
The builder is designed as a modal overlay that can be triggered from anywhere in your application:

```javascript
// Open the builder
openTrainingBuilder();

// Close the builder
closeTrainingBuilder();
```

### 2. Firebase Configuration

#### Required Collections

##### `trainingPrograms` Collection
Programs are saved with the following structure:

```javascript
{
  // Basic Information
  title: "4 Weeks Hardcore Abs",
  description: "Intensive core training program...",
  duration: "4_weeks",
  frequency: "4_days",
  trainingDays: ["monday", "tuesday", "thursday", "friday"],
  trainingStyle: "standard_gym",
  
  // Workout Structure
  workouts: {
    monday: {
      exercises: [
        {
          id: "plank",
          name: "Plank",
          description: "Hold a plank position",
          category: "Core",
          subcategory: "Abs",
          type: "duration", // or "reps"
          sets: 3,
          reps: 12, // if type is "reps"
          duration: 30, // if type is "duration" (seconds)
          rest: 60, // seconds
          weight: "", // optional
          notes: "Keep core tight"
        }
        // ... more exercises
      ]
    }
    // ... other days
  },
  
  // Metadata
  createdBy: "user_uid",
  createdAt: Firestore.Timestamp,
  updatedAt: Firestore.Timestamp,
  isActive: true,
  version: 1
}
```

##### `exercises` Collection (Optional)
If you want to load exercises from Firestore instead of using the built-in database:

```javascript
{
  id: "plank",
  name: "Plank",
  description: "Hold a plank position",
  category: "core", // core, upper_body, lower_body, cardio, etc.
  subcategory: "abs", // abs, obliques, chest, back, etc.
  instructions: "Detailed exercise instructions...",
  equipment: ["bodyweight"], // equipment needed
  difficulty: "beginner", // beginner, intermediate, advanced
  muscleGroups: ["abs", "core"], // primary muscle groups
  videoUrl: "https://...", // optional video demonstration
  imageUrl: "https://...", // optional image
  createdAt: Firestore.Timestamp,
  isActive: true
}
```

#### Firebase Security Rules

Add these security rules to your Firestore:

```javascript
// Training Programs Rules
match /trainingPrograms/{programId} {
  allow read, write: if request.auth != null && 
    (resource == null || resource.data.createdBy == request.auth.uid);
}

// Exercises Rules (if using Firestore exercises)
match /exercises/{exerciseId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### 3. Configuration Options

#### Firebase Config
Update the Firebase configuration in the HTML file:

```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "your-sender-id",
  appId: "your-app-id"
};
```

#### Exercise Database Customization
Modify the `exerciseDatabase` object to add your own exercises:

```javascript
const exerciseDatabase = {
  core: {
    abs: [
      {
        id: 'custom_exercise',
        name: 'Custom Exercise',
        description: 'Your custom exercise description',
        category: 'Core',
        subcategory: 'Abs'
      }
    ]
  }
  // Add more categories and exercises
};
```

## Step-by-Step Workflow

### Step 1: Program Details
- **Program Title**: Required text input
- **Description**: Optional textarea for program overview
- **Duration**: Dropdown with preset options (1-12 weeks) or custom duration

### Step 2: Weekly Schedule
- **Frequency Selection**: Choose how many days per week to train (3-7 days)
- **Visual Selection**: Checkbox-style interface for easy selection

### Step 3: Training Days
- **Day Selection**: Choose specific days of the week to train
- **Validation**: Ensures selected days match the chosen frequency
- **Visual Feedback**: Shows progress toward required selection count

### Step 4: Training Style
- **Standard Gym**: Traditional reps and sets approach
- **Metabolic Circuit**: High-intensity circuit training
- **AMRAP**: As Many Reps As Possible format
- **Time-Based**: Duration-focused exercises
- **Hybrid**: Combination of multiple styles

### Step 5: Exercise Selection
For each selected training day:
- **Exercise Browser**: Categorized list of exercises by body part
- **Exercise Configuration**: 
  - Type (reps vs duration)
  - Sets count
  - Reps/duration amount
  - Rest periods
  - Optional notes
- **Dynamic Interface**: Configuration options change based on training style

### Step 6: Review & Save
- **Program Summary**: Complete overview of the created program
- **Validation**: Final check for completeness
- **Firebase Save**: Stores program to Firestore with metadata

## Customization Guide

### Styling Customization
The application uses CSS custom properties for easy theming:

```css
:root {
  --primary-color: #007bff;        /* Main brand color */
  --primary-dark: #0056b3;         /* Darker variant */
  --secondary-color: #6c757d;      /* Secondary elements */
  --success-color: #28a745;        /* Success states */
  --danger-color: #dc3545;         /* Error states */
  --warning-color: #ffc107;        /* Warning states */
  --info-color: #17a2b8;           /* Info states */
  --light-color: #f8f9fa;          /* Light backgrounds */
  --dark-color: #343a40;           /* Text color */
  --border-radius: 8px;            /* Border radius */
  --box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  --transition: all 0.3s ease;     /* Transitions */
}
```

### Adding Custom Exercise Categories
```javascript
// Add new category to exerciseDatabase
exerciseDatabase.cardio = {
  running: [
    {
      id: 'sprint_intervals',
      name: 'Sprint Intervals',
      description: 'High-intensity sprint training',
      category: 'Cardio',
      subcategory: 'Running'
    }
  ],
  cycling: [
    // ... cycling exercises
  ]
};
```

### Custom Training Styles
Add new training styles by modifying the step 4 interface:

```html
<div class="checkbox-item" onclick="selectTrainingStyle('powerlifting')">
  <input type="radio" name="trainingStyle" value="powerlifting" id="stylePowerlifting">
  <label for="stylePowerlifting">Powerlifting (Heavy Sets)</label>
</div>
```

## API Integration for Flutter

### Fetching Programs
```dart
// Fetch user's training programs
Stream<List<TrainingProgram>> getUserPrograms(String userId) {
  return FirebaseFirestore.instance
    .collection('trainingPrograms')
    .where('createdBy', isEqualTo: userId)
    .where('isActive', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => TrainingProgram.fromFirestore(doc))
        .toList());
}
```

### Program Data Model
```dart
class TrainingProgram {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String frequency;
  final List<String> trainingDays;
  final String trainingStyle;
  final Map<String, WorkoutDay> workouts;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int version;

  // Constructor and methods...
}

class WorkoutDay {
  final List<Exercise> exercises;
  
  // Constructor and methods...
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String type; // 'reps' or 'duration'
  final int sets;
  final int? reps;
  final int? duration;
  final int rest;
  final String? weight;
  final String? notes;
  
  // Constructor and methods...
}
```

## Error Handling

### Client-Side Validation
- Required field validation at each step
- Logical validation (e.g., exercise count matches training days)
- Real-time feedback with visual indicators

### Firebase Error Handling
```javascript
try {
  await addDoc(collection(db, 'trainingPrograms'), programData);
  // Success handling
} catch (error) {
  console.error('Save error:', error);
  
  // Handle specific error types
  if (error.code === 'permission-denied') {
    alert('You do not have permission to save programs.');
  } else if (error.code === 'unavailable') {
    alert('Service temporarily unavailable. Please try again.');
  } else {
    alert('Failed to save program. Please check your connection.');
  }
}
```

## Performance Optimization

### Lazy Loading
- Exercise database loaded on demand
- Modal content rendered only when opened
- Step content loaded progressively

### Data Efficiency
- Minimal data transfer to Firestore
- Optimized exercise selection interface
- Debounced validation checks

## Testing Guide

### Manual Testing Checklist
1. **Modal Functionality**
   - [ ] Modal opens and closes correctly
   - [ ] Progress bar updates properly
   - [ ] Navigation between steps works

2. **Form Validation**
   - [ ] Required fields prevent progression
   - [ ] Custom duration validation
   - [ ] Training day count validation
   - [ ] Exercise selection validation

3. **Exercise Management**
   - [ ] Exercise selection works
   - [ ] Configuration updates properly
   - [ ] Exercise removal works
   - [ ] Different training styles work

4. **Firebase Integration**
   - [ ] Authentication required
   - [ ] Data saves correctly
   - [ ] Error handling works
   - [ ] Success feedback shows

### Automated Testing
```javascript
// Example Jest test
describe('Training Program Builder', () => {
  test('validates required program title', () => {
    const isValid = validateProgramDetails();
    expect(isValid).toBe(false);
    
    document.getElementById('programTitle').value = 'Test Program';
    expect(validateProgramDetails()).toBe(true);
  });
});
```

## Deployment Considerations

### Security
- Ensure Firebase authentication is properly configured
- Validate user permissions before saving
- Sanitize user input to prevent XSS

### Performance
- Optimize images and assets
- Use CDN for Firebase SDKs
- Implement proper caching strategies

### Monitoring
- Set up Firebase Analytics for usage tracking
- Monitor Firestore usage and costs
- Track user engagement with different features

## Future Enhancements

### Planned Features
1. **Program Templates**: Pre-built program templates for common goals
2. **Exercise Videos**: Integration with exercise demonstration videos
3. **Progress Tracking**: Track user progress through programs
4. **Program Sharing**: Share programs between users
5. **AI Recommendations**: Suggest exercises based on goals
6. **Nutrition Integration**: Add meal planning to programs
7. **Export Options**: Export programs to PDF or other formats

### Technical Improvements
1. **Offline Support**: PWA with offline capabilities
2. **Real-time Collaboration**: Multiple users editing programs
3. **Version Control**: Track program changes and revisions
4. **Advanced Analytics**: Detailed usage analytics
5. **Integration APIs**: REST API for third-party integrations

## Support and Troubleshooting

### Common Issues

#### Modal Not Opening
- Check if Firebase is properly initialized
- Verify no JavaScript errors in console
- Ensure trigger function is properly attached

#### Exercises Not Loading
- Check exercise database structure
- Verify Firestore connection
- Check browser console for errors

#### Save Failures
- Verify user authentication status
- Check Firestore security rules
- Monitor network connectivity

### Debug Mode
Enable debug mode by setting:
```javascript
window.DEBUG_MODE = true;
```

This will provide detailed console logging for troubleshooting.

## License and Credits

This Training Program Builder is designed for integration with the Wise Fitness platform and includes comprehensive exercise database and flexible program creation capabilities.

For support or questions, refer to the project documentation or contact the development team.
