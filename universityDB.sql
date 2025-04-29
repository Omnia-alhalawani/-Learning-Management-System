-- ======== TABLE CREATION ========

-- Users table (for both Admins and Students)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    UserType VARCHAR(20) NOT NULL CHECK (UserType IN ('Admin', 'Student')),
    ProfilePicture VARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLoginDate DATETIME,
    IsActive BIT DEFAULT 1
);
-- Courses table
CREATE TABLE Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    CourseDescription TEXT,
    CreatedByUserID INT NOT NULL,
    CreationDate DATETIME DEFAULT GETDATE(),
    StartDate DATETIME,
    EndDate DATETIME,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID)
);
-- Course enrollments (links Students to Courses)
CREATE TABLE CourseEnrollments (
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL,
    StudentID INT NOT NULL,
    EnrollmentDate DATETIME DEFAULT GETDATE(),
    CompletionStatus VARCHAR(20) DEFAULT 'In Progress' CHECK (CompletionStatus IN ('Not Started', 'In Progress', 'Completed')),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT UQ_Enrollment UNIQUE (CourseID, StudentID)
);
-- Course materials
CREATE TABLE Materials (
    MaterialID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL,
    MaterialTitle VARCHAR(100) NOT NULL,
    MaterialType VARCHAR(20) NOT NULL CHECK (MaterialType IN ('PDF', 'Video', 'Document', 'Link', 'Other')),
    FilePath VARCHAR(255),
    UploadDate DATETIME DEFAULT GETDATE(),
    UploadedByUserID INT NOT NULL,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (UploadedByUserID) REFERENCES Users(UserID)
);
-- Quizzes
CREATE TABLE Quizzes (
    QuizID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL,
    QuizTitle VARCHAR(100) NOT NULL,
    Description TEXT,
    TimeLimit INT, -- in minutes
    DueDate DATETIME,
    CreatedByUserID INT NOT NULL,
    CreationDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID)
);
-- Quiz questions
CREATE TABLE Questions (
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID INT NOT NULL,
    QuestionText TEXT NOT NULL,
    QuestionType VARCHAR(20) NOT NULL CHECK (QuestionType IN ('MultipleChoice', 'TrueFalse', 'ShortAnswer')),
    Points INT DEFAULT 1,
    FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID)
);
-- Answer options for multiple-choice questions
CREATE TABLE AnswerOptions (
    OptionID INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID INT NOT NULL,
    OptionText TEXT NOT NULL,
    IsCorrect BIT DEFAULT 0,
    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID)
);
-- Quiz attempts by students
CREATE TABLE QuizAttempts (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID INT NOT NULL,
    StudentID INT NOT NULL,
    StartTime DATETIME DEFAULT GETDATE(),
    EndTime DATETIME,
    Score DECIMAL(5,2),
    IsCompleted BIT DEFAULT 0,
    FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID),
    FOREIGN KEY (StudentID) REFERENCES Users(UserID)
);
-- Student answers for quiz attempts
CREATE TABLE StudentAnswers (
    AnswerID INT IDENTITY(1,1) PRIMARY KEY,
    AttemptID INT NOT NULL,
    QuestionID INT NOT NULL,
    SelectedOptionID INT, -- For multiple choice
    TextAnswer TEXT, -- For short answer
    IsCorrect BIT,
    PointsEarned DECIMAL(5,2),
    FOREIGN KEY (AttemptID) REFERENCES QuizAttempts(AttemptID),
    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID),
    FOREIGN KEY (SelectedOptionID) REFERENCES AnswerOptions(OptionID)
);
-- Assignments
CREATE TABLE Assignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL,
    AssignmentTitle VARCHAR(100) NOT NULL,
    Description TEXT,
    DueDate DATETIME,
    TotalPoints INT DEFAULT 100,
    CreatedByUserID INT NOT NULL,
    CreationDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID)
);
-- Assignment submissions
CREATE TABLE AssignmentSubmissions (
    SubmissionID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID INT NOT NULL,
    StudentID INT NOT NULL,
    SubmissionDate DATETIME DEFAULT GETDATE(),
    FilePath VARCHAR(255),
    Comments TEXT,
    Grade DECIMAL(5,2),
    GradedByUserID INT,
    GradedDate DATETIME,
    FOREIGN KEY (AssignmentID) REFERENCES Assignments(AssignmentID),
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    FOREIGN KEY (GradedByUserID) REFERENCES Users(UserID)
);
-- Messages
CREATE TABLE Messages (
    MessageID INT IDENTITY(1,1) PRIMARY KEY,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    Subject VARCHAR(100),
    MessageContent TEXT NOT NULL,
    SentDate DATETIME DEFAULT GETDATE(),
    IsRead BIT DEFAULT 0,
    IsDeletedBySender BIT DEFAULT 0,
    IsDeletedByReceiver BIT DEFAULT 0,
    FOREIGN KEY (SenderID) REFERENCES Users(UserID),
    FOREIGN KEY (ReceiverID) REFERENCES Users(UserID)
);
-- Notifications
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    NotificationType VARCHAR(50) NOT NULL,
    NotificationContent TEXT NOT NULL,
    RelatedEntityID INT, -- Could reference a course, assignment, etc.
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsRead BIT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
-- User sessions for security/monitoring
CREATE TABLE UserSessions (
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    SessionToken VARCHAR(255) NOT NULL,
    IPAddress VARCHAR(50),
    LoginTime DATETIME DEFAULT GETDATE(),
    LogoutTime DATETIME,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
-- System settings/configuration
CREATE TABLE SystemSettings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingName VARCHAR(50) NOT NULL UNIQUE,
    SettingValue VARCHAR(255) NOT NULL,
    Description VARCHAR(255),
    LastModifiedDate DATETIME DEFAULT GETDATE(),
    LastModifiedByUserID INT,
    FOREIGN KEY (LastModifiedByUserID) REFERENCES Users(UserID)
);
-- ======== INDEX CREATION ========

-- Create indexes for performance optimization
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_UserType ON Users(UserType);
CREATE INDEX IX_CourseEnrollments_StudentID ON CourseEnrollments(StudentID);
CREATE INDEX IX_CourseEnrollments_CourseID ON CourseEnrollments(CourseID);
CREATE INDEX IX_Materials_CourseID ON Materials(CourseID);
CREATE INDEX IX_Quizzes_CourseID ON Quizzes(CourseID);
CREATE INDEX IX_Questions_QuizID ON Questions(QuizID);
CREATE INDEX IX_QuizAttempts_StudentID ON QuizAttempts(StudentID);
CREATE INDEX IX_QuizAttempts_QuizID ON QuizAttempts(QuizID);
CREATE INDEX IX_Messages_SenderID ON Messages(SenderID);
CREATE INDEX IX_Messages_ReceiverID ON Messages(ReceiverID);
CREATE INDEX IX_Notifications_UserID ON Notifications(UserID);
CREATE INDEX IX_Assignments_CourseID ON Assignments(CourseID);
CREATE INDEX IX_AssignmentSubmissions_AssignmentID ON AssignmentSubmissions(AssignmentID);
CREATE INDEX IX_AssignmentSubmissions_StudentID ON AssignmentSubmissions(StudentID);



-- ======== USERS INSERTION ========
-- Insert Users (Admins and Students)
INSERT INTO Users (Email, PasswordHash, FirstName, LastName, UserType, ProfilePicture, CreatedDate, LastLoginDate, IsActive)
VALUES
-- Admins
('admin.johnson@lms.edu', 'hashed_password_1', 'Robert', 'Johnson', 'Admin', '/profiles/rjohnson.jpg', '2024-01-15', '2025-04-27', 1),
('admin.williams@lms.edu', 'hashed_password_2', 'Susan', 'Williams', 'Admin', '/profiles/swilliams.jpg', '2024-01-20', '2025-04-26', 1),
('admin.davis@lms.edu', 'hashed_password_3', 'Michael', 'Davis', 'Admin', '/profiles/mdavis.jpg', '2024-02-05', '2025-04-25', 1),

-- Students
('john.smith@student.edu', 'hashed_password_4', 'John', 'Smith', 'Student', '/profiles/jsmith.jpg', '2024-02-10', '2025-04-27', 1),
('emily.jones@student.edu', 'hashed_password_5', 'Emily', 'Jones', 'Student', '/profiles/ejones.jpg', '2024-02-12', '2025-04-26', 1),
('david.wilson@student.edu', 'hashed_password_6', 'David', 'Wilson', 'Student', '/profiles/dwilson.jpg', '2024-02-15', '2025-04-25', 1),
('sarah.brown@student.edu', 'hashed_password_7', 'Sarah', 'Brown', 'Student', '/profiles/sbrown.jpg', '2024-02-20', '2025-04-24', 1),
('michael.taylor@student.edu', 'hashed_password_8', 'Michael', 'Taylor', 'Student', '/profiles/mtaylor.jpg', '2024-02-22', '2025-04-23', 1),
('jennifer.miller@student.edu', 'hashed_password_9', 'Jennifer', 'Miller', 'Student', '/profiles/jmiller.jpg', '2024-03-01', '2025-04-22', 1),
('ryan.anderson@student.edu', 'hashed_password_10', 'Ryan', 'Anderson', 'Student', '/profiles/randerson.jpg', '2024-03-05', '2025-04-21', 1),
('lisa.thomas@student.edu', 'hashed_password_11', 'Lisa', 'Thomas', 'Student', '/profiles/lthomas.jpg', '2024-03-10', '2025-04-20', 1),
('james.jackson@student.edu', 'hashed_password_12', 'James', 'Jackson', 'Student', '/profiles/jjackson.jpg', '2024-03-15', '2025-04-19', 1),
('amanda.white@student.edu', 'hashed_password_13', 'Amanda', 'White', 'Student', '/profiles/awhite.jpg', '2024-03-20', '2025-04-18', 1);


-- ======== COURSES INSERTION ========
-- Insert Courses
INSERT INTO Courses (CourseName, CourseDescription, CreatedByUserID, CreationDate, StartDate, EndDate, IsActive)
VALUES
('Introduction to Computer Science', 'Fundamental concepts of computer science, including algorithms, data structures, and programming basics.', 1, '2024-03-01', '2025-01-15', '2025-05-30', 1),
('Advanced Mathematics', 'Covers calculus, linear algebra, and differential equations for STEM majors.', 2, '2024-03-05', '2025-01-15', '2025-05-30', 1),
('Business Communication', 'Effective communication strategies in business contexts, including presentations and report writing.', 3, '2024-03-10', '2025-01-15', '2025-05-30', 1),
('Introduction to Psychology', 'Overview of basic psychological principles, theories, and research methods.', 1, '2024-03-15', '2025-01-15', '2025-05-30', 1),
('Data Science Fundamentals', 'Introduction to data analysis, visualization, and basic statistical methods.', 2, '2024-03-20', '2025-01-15', '2025-05-30', 1);

-- ======== COURSE ENROLLMENTS INSERTION ========
-- Insert Course Enrollments
INSERT INTO CourseEnrollments (CourseID, StudentID, EnrollmentDate, CompletionStatus)
VALUES
-- Intro to CS enrollments
(1, 4, '2025-01-10', 'In Progress'),
(1, 5, '2025-01-11', 'In Progress'),
(1, 6, '2025-01-12', 'In Progress'),
(1, 7, '2025-01-13', 'In Progress'),

-- Advanced Mathematics enrollments
(2, 5, '2025-01-10', 'In Progress'),
(2, 8, '2025-01-12', 'In Progress'),
(2, 9, '2025-01-14', 'In Progress'),

-- Business Communication enrollments
(3, 4, '2025-01-09', 'In Progress'),
(3, 6, '2025-01-11', 'In Progress'),
(3, 10, '2025-01-13', 'In Progress'),
(3, 11, '2025-01-15', 'In Progress'),

-- Intro to Psychology enrollments
(4, 7, '2025-01-08', 'In Progress'),
(4, 8, '2025-01-10', 'In Progress'),
(4, 10, '2025-01-12', 'In Progress'),
(4, 13, '2025-01-14', 'In Progress'),

-- Data Science Fundamentals enrollments
(5, 9, '2025-01-09', 'In Progress'),
(5, 11, '2025-01-11', 'In Progress'),
(5, 12, '2025-01-13', 'In Progress'),
(5, 13, '2025-01-15', 'In Progress');


-- ======== MATERIALS INSERTION ========
-- Insert Materials
INSERT INTO Materials (CourseID, MaterialTitle, MaterialType, FilePath, UploadDate, UploadedByUserID, IsActive)
VALUES
-- Intro to CS materials
(1, 'Introduction to Algorithms', 'PDF', '/materials/cs/intro_algorithms.pdf', '2025-01-05', 1, 1),
(1, 'Python Programming Basics', 'PDF', '/materials/cs/python_basics.pdf', '2025-01-05', 1, 1),
(1, 'Data Structures Overview', 'Video', '/materials/cs/data_structures.mp4', '2025-01-06', 1, 1),
(1, 'Object-Oriented Programming', 'Document', '/materials/cs/oop_concepts.docx', '2025-01-07', 1, 1),

-- Advanced Mathematics materials
(2, 'Calculus Fundamentals', 'PDF', '/materials/math/calculus_fundamentals.pdf', '2025-01-05', 2, 1),
(2, 'Linear Algebra Lecture Notes', 'PDF', '/materials/math/linear_algebra.pdf', '2025-01-06', 2, 1),
(2, 'Differential Equations Tutorial', 'Video', '/materials/math/diff_equations.mp4', '2025-01-07', 2, 1),

-- Business Communication materials
(3, 'Effective Presentation Skills', 'PDF', '/materials/business/presentations.pdf', '2025-01-05', 3, 1),
(3, 'Business Writing Guidelines', 'Document', '/materials/business/writing_guide.docx', '2025-01-06', 3, 1),
(3, 'Communication Strategy Examples', 'PDF', '/materials/business/comm_strategies.pdf', '2025-01-07', 3, 1),

-- Intro to Psychology materials
(4, 'Introduction to Psychological Theories', 'PDF', '/materials/psych/intro_theories.pdf', '2025-01-05', 1, 1),
(4, 'Research Methods in Psychology', 'Video', '/materials/psych/research_methods.mp4', '2025-01-06', 1, 1),
(4, 'Cognitive Psychology Overview', 'PDF', '/materials/psych/cognitive_psych.pdf', '2025-01-07', 1, 1),

-- Data Science materials
(5, 'Introduction to Data Analysis', 'PDF', '/materials/data/intro_analysis.pdf', '2025-01-05', 2, 1),
(5, 'Statistical Methods Overview', 'PDF', '/materials/data/statistics_methods.pdf', '2025-01-06', 2, 1),
(5, 'Data Visualization Techniques', 'Video', '/materials/data/data_viz.mp4', '2025-01-07', 2, 1);


-- ======== QUIZZES INSERTION ========
-- Insert Quizzes
INSERT INTO Quizzes (CourseID, QuizTitle, Description, TimeLimit, DueDate, CreatedByUserID, CreationDate, IsActive)
VALUES
(1, 'Programming Fundamentals Quiz', 'Test your understanding of basic programming concepts.', 30, '2025-02-15', 1, '2025-01-20', 1),
(1, 'Data Structures Mid-term', 'Comprehensive assessment of data structures knowledge.', 60, '2025-03-15', 1, '2025-01-25', 1),
(2, 'Calculus Quiz 1', 'Assessment of basic calculus concepts.', 45, '2025-02-20', 2, '2025-01-20', 1),
(3, 'Business Writing Assessment', 'Evaluation of business writing skills and knowledge.', 40, '2025-02-25', 3, '2025-01-22', 1),
(4, 'Psychological Theories Quiz', 'Test on fundamental psychological theories.', 30, '2025-02-10', 1, '2025-01-15', 1),
(5, 'Data Analysis Techniques Quiz', 'Assessment of basic data analysis methods.', 45, '2025-02-28', 2, '2025-01-25', 1);


-- ======== QUESTIONS INSERTION ========
-- Insert Questions
INSERT INTO Questions (QuizID, QuestionText, QuestionType, Points)
VALUES
-- Programming Fundamentals Quiz questions
(1, 'What is a variable in programming?', 'MultipleChoice', 5),
(1, 'Which of the following is NOT a data type in most programming languages?', 'MultipleChoice', 5),
(1, 'True or False: Python is a compiled language.', 'TrueFalse', 5),
(1, 'Explain what a loop is and provide an example.', 'ShortAnswer', 10),

-- Data Structures Mid-term questions
(2, 'Which data structure follows LIFO principle?', 'MultipleChoice', 5),
(2, 'What is the time complexity of searching in a binary search tree in the worst case?', 'MultipleChoice', 5),
(2, 'True or False: A linked list requires contiguous memory allocation.', 'TrueFalse', 5),
(2, 'Explain the difference between a stack and a queue.', 'ShortAnswer', 10),

-- Calculus Quiz questions
(3, 'What is the derivative of f(x) = x²?', 'MultipleChoice', 5),
(3, 'Which of the following is the integral of cos(x)?', 'MultipleChoice', 5),
(3, 'True or False: The product rule states that the derivative of a product equals the product of the derivatives.', 'TrueFalse', 5),
(3, 'Explain what a limit is in calculus and provide an example.', 'ShortAnswer', 10),

-- Business Writing Assessment questions
(4, 'Which of the following is NOT a characteristic of effective business writing?', 'MultipleChoice', 5),
(4, 'What is the recommended structure for a business report?', 'MultipleChoice', 5),
(4, 'True or False: Passive voice is preferred in business communication.', 'TrueFalse', 5),
(4, 'Describe the key elements of an effective business email.', 'ShortAnswer', 10),

-- Psychological Theories Quiz questions 
(5, 'Who developed the theory of psychoanalysis?', 'MultipleChoice', 5),
(5, 'Which psychological perspective emphasizes observable behavior?', 'MultipleChoice', 5),
(5, 'True or False: Maslow''s hierarchy of needs places self-actualization at the bottom of the pyramid.', 'TrueFalse', 5),
(5, 'Explain the difference between classical and operant conditioning.', 'ShortAnswer', 10),

-- Data Analysis Techniques Quiz questions
(6, 'Which measure of central tendency is most affected by outliers?', 'MultipleChoice', 5),
(6, 'What type of graph is best for showing the distribution of a continuous variable?', 'MultipleChoice', 5),
(6, 'True or False: Correlation always implies causation.', 'TrueFalse', 5),
(6, 'Describe the purpose of data normalization and when it should be used.', 'ShortAnswer', 10);


-- ======== ANSWER OPTIONS INSERTION ========
-- Insert Answer Options
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect)
VALUES
-- Programming Fundamentals Quiz answers
(1, 'A container that stores data values', 1),
(1, 'A mathematical operation', 0),
(1, 'A type of function', 0),
(1, 'A programming language', 0),

(2, 'Integer', 0),
(2, 'Float', 0),
(2, 'Character', 0),
(2, 'Program', 1),

(3, 'True', 0),
(3, 'False', 1),

-- Data Structures Mid-term answers
(5, 'Queue', 0),
(5, 'Stack', 1),
(5, 'Array', 0),
(5, 'Linked List', 0),

(6, 'O(1)', 0),
(6, 'O(log n)', 0),
(6, 'O(n)', 0),
(6, 'O(n log n)', 1),

(7, 'True', 0),
(7, 'False', 1),

-- Calculus Quiz answers
(9, 'f''(x) = x', 0),
(9, 'f''(x) = 2x', 1),
(9, 'f''(x) = x²', 0),
(9, 'f''(x) = 2', 0),

(10, 'sin(x)', 1),
(10, '-sin(x)', 0),
(10, 'tan(x)', 0),
(10, 'sec(x)', 0),

(11, 'True', 0),
(11, 'False', 1),

-- Business Writing answers
(13, 'Clarity', 0),
(13, 'Conciseness', 0),
(13, 'Verbosity', 1),
(13, 'Accuracy', 0),

(14, 'Introduction, Body, Conclusion', 1),
(14, 'Abstract, Discussion, References', 0),
(14, 'Title, Content, Bibliography', 0),
(14, 'Summary, Analysis, Recommendation', 0),

(15, 'True', 0),
(15, 'False', 1),

-- Psychological Theories Quiz answers
(17, 'B.F. Skinner', 0),
(17, 'Carl Rogers', 0),
(17, 'Sigmund Freud', 1),
(17, 'Albert Bandura', 0),

(18, 'Psychoanalytic', 0),
(18, 'Humanistic', 0),
(18, 'Cognitive', 0),
(18, 'Behaviorist', 1),

(19, 'True', 0),
(19, 'False', 1),

-- Data Analysis Techniques Quiz answers
(21, 'Mean', 1),
(21, 'Median', 0),
(21, 'Mode', 0),
(21, 'Range', 0),

(22, 'Pie chart', 0),
(22, 'Bar graph', 0),
(22, 'Histogram', 1),
(22, 'Scatter plot', 0),

(23, 'True', 0),
(23, 'False', 1);


-- ======== QUIZ ATTEMPTS INSERTION ========
-- Insert Quiz Attempts
INSERT INTO QuizAttempts (QuizID, StudentID, StartTime, EndTime, Score, IsCompleted)
VALUES
-- Programming Fundamentals Quiz attempts
(1, 4, '2025-02-14 10:00:00', '2025-02-14 10:25:00', 85.00, 1),
(1, 5, '2025-02-14 11:30:00', '2025-02-14 11:55:00', 90.00, 1),
(1, 6, '2025-02-15 09:00:00', '2025-02-15 09:28:00', 75.00, 1),
(1, 7, '2025-02-15 14:00:00', '2025-02-15 14:27:00', 95.00, 1),

-- Calculus Quiz attempts
(3, 5, '2025-02-20 13:00:00', '2025-02-20 13:40:00', 80.00, 1),
(3, 8, '2025-02-20 15:30:00', '2025-02-20 16:10:00', 85.00, 1),
(3, 9, '2025-02-20 17:00:00', '2025-02-20 17:42:00', 70.00, 1),

-- Psychological Theories Quiz attempts
(5, 7, '2025-02-10 09:30:00', '2025-02-10 09:55:00', 90.00, 1),
(5, 8, '2025-02-10 10:15:00', '2025-02-10 10:42:00', 80.00, 1),
(5, 10, '2025-02-10 14:00:00', '2025-02-10 14:28:00', 95.00, 1),
(5, 13, '2025-02-10 16:30:00', '2025-02-10 16:58:00', 85.00, 1);

-- ======== STUDENT ANSWERS INSERTION ========
-- Insert Student Answers
INSERT INTO StudentAnswers (AttemptID, QuestionID, SelectedOptionID, TextAnswer, IsCorrect, PointsEarned)
VALUES
-- John Smith's answers to Programming Quiz
(1, 1, 1, NULL, 1, 5.00),
(1, 2, 8, NULL, 1, 5.00),
(1, 3, 10, NULL, 1, 5.00),
(1, 4, NULL, 'A loop is a programming structure that repeats a sequence of instructions until a specific condition is met. Example: for i in range(10): print(i)', 0, 8.50),

-- Emily Jones's answers to Programming Quiz
(2, 1, 1, NULL, 1, 5.00),
(2, 2, 8, NULL, 1, 5.00),
(2, 3, 10, NULL, 1, 5.00),
(2, 4, NULL, 'A loop is a control flow statement that allows code to be executed repeatedly based on a condition. Examples include for loops and while loops.', 1, 10.00),

-- Emily Jones's answers to Calculus Quiz
(5, 9, 10, NULL, 1, 5.00),
(5, 10, 13, NULL, 1, 5.00),
(5, 11, 15, NULL, 1, 5.00),
(5, 12, NULL, 'A limit describes the behavior of a function as its input approaches a certain value. Example: lim(x→0) sin(x)/x = 1', 1, 10.00),

-- Sarah Brown's answers to Psychological Theories Quiz
(8, 17, 21, NULL, 1, 5.00),
(8, 18, 26, NULL, 1, 5.00),
(8, 19, 28, NULL, 1, 5.00),
(8, 20, NULL, 'Classical conditioning involves associating an involuntary response with a stimulus, while operant conditioning involves associating behaviors with consequences.', 1, 10.00);


-- ======== ASSIGNMENTS INSERTION ========
-- Insert Assignments
INSERT INTO Assignments (CourseID, AssignmentTitle, Description, DueDate, TotalPoints, CreatedByUserID, CreationDate, IsActive)
VALUES
(1, 'Python Programming Project', 'Create a simple calculator application using Python.', '2025-03-01', 100, 1, '2025-01-25', 1),
(1, 'Algorithm Analysis Paper', 'Write a paper analyzing the efficiency of sorting algorithms.', '2025-04-01', 100, 1, '2025-01-30', 1),
(2, 'Calculus Problem Set', 'Complete the problem set on derivatives and integrals.', '2025-03-05', 50, 2, '2025-01-28', 1),
(3, 'Business Proposal Writing', 'Write a business proposal for a fictional product launch.', '2025-03-10', 100, 3, '2025-01-27', 1),
(4, 'Psychology Research Summary', 'Summarize a recent research article in psychology.', '2025-03-15', 75, 1, '2025-01-26', 1),
(5, 'Data Analysis Project', 'Analyze the provided dataset and create visualizations.', '2025-03-20', 100, 2, '2025-01-29', 1);

-- ======== ASSIGNMENT SUBMISSIONS INSERTION ========
INSERT INTO AssignmentSubmissions (AssignmentID, StudentID, SubmissionDate, FilePath, Comments, Grade, GradedByUserID, GradedDate)
VALUES
-- Python Programming Project submissions
(1, 4, '2025-02-28 15:30:00', '/submissions/smith_calculator.py', 'Implemented all required functionality.', 92.5, 1, '2025-03-03'),
(1, 5, '2025-02-27 10:15:00', '/submissions/jones_calculator.py', 'Great work! Included additional features.', 98.0, 1, '2025-03-03'),
(1, 6, '2025-02-28 23:45:00', '/submissions/wilson_calculator.py', 'Basic implementation, some bugs.', 85.0, 1, '2025-03-03'),
(1, 7, '2025-02-26 14:20:00', '/submissions/brown_calculator.py', 'Excellent implementation with error handling.', 95.0, 1, '2025-03-02'),

-- Calculus Problem Set submissions
(3, 5, '2025-03-04 18:30:00', '/submissions/jones_calculus.pdf', 'All problems solved correctly.', 48.0, 2, '2025-03-06'),
(3, 8, '2025-03-05 09:45:00', '/submissions/taylor_calculus.pdf', 'Good work with minor calculation errors.', 45.0, 2, '2025-03-06'),
(3, 9, '2025-03-04 22:10:00', '/submissions/miller_calculus.pdf', 'Several errors in integration problems.', 38.0, 2, '2025-03-06'),

-- Business Proposal Writing submissions
(4, 4, '2025-03-09 16:20:00', '/submissions/smith_proposal.docx', 'Well-structured proposal with strong arguments.', 90.0, 3, '2025-03-12'),
(4, 6, '2025-03-10 10:05:00', '/submissions/wilson_proposal.docx', 'Good content but needs better organization.', 85.0, 3, '2025-03-12'),
(4, 10, '2025-03-08 14:30:00', '/submissions/anderson_proposal.docx', 'Excellent proposal with detailed analysis.', 95.0, 3, '2025-03-11'),
(4, 11, '2025-03-10 09:55:00', '/submissions/thomas_proposal.docx', 'Decent proposal but lacks market analysis.', 80.0, 3, '2025-03-12');


-- ======== MESSAGES INSERTION ========
-- Insert Messages
INSERT INTO Messages (SenderID, ReceiverID, Subject, MessageContent, SentDate, IsRead)
VALUES
-- Admin to Student messages
(1, 4, 'Assignment Feedback', 'Your calculator project was well done. Consider adding error handling in future projects.', '2025-03-03 15:00:00', 1),
(2, 5, 'Question about your calculus submission', 'Could you clarify your approach to problem #5? I want to ensure I understand your method.', '2025-03-07 10:30:00', 1),
(3, 6, 'Business Proposal Feedback', 'Your proposal had good ideas but needs better organization. Let me know if you need help with this.', '2025-03-13 09:15:00', 0),

-- Student to Admin messages
(4, 1, 'Question about next assignment', 'I have a question about the requirements for the algorithm analysis paper. Could we discuss during office hours?', '2025-03-04 11:45:00', 1),
(5, 2, 'Clarification on calculus problem', 'I''m struggling with the integration techniques for problem #8. Could you provide an example?', '2025-03-06 14:20:00', 1),
(7, 1, 'Request for additional resources', 'Do you have any additional resources on object-oriented programming concepts?', '2025-03-05 16:10:00', 0),

-- Student to Student messages
(4, 5, 'Study group for CS', 'Would you like to form a study group for the upcoming CS exam?', '2025-03-10 13:25:00', 1),
(5, 4, 'RE: Study group for CS', 'Yes, that sounds great! Shall we meet in the library on Thursday?', '2025-03-10 14:50:00', 1),
(8, 9, 'Math homework help', 'Are you free to help with the calculus homework problems this weekend?', '2025-03-12 19:30:00', 0);



-- ======== QUIZ ATTEMPTS INSERTION ========
-- Insert Quiz Attempts
INSERT INTO QuizAttempts (QuizID, StudentID, StartTime, EndTime, Score, IsCompleted)
VALUES
-- Programming Fundamentals Quiz attempts
(1, 4, '2025-02-14 10:00:00', '2025-02-14 10:25:00', 85.00, 1),
(1, 5, '2025-02-14 11:30:00', '2025-02-14 11:55:00', 90.00, 1),
(1, 6, '2025-02-15 09:00:00', '2025-02-15 09:28:00', 75.00, 1),
(1, 7, '2025-02-15 14:00:00', '2025-02-15 14:27:00', 95.00, 1),

-- Calculus Quiz attempts
(3, 5, '2025-02-20 13:00:00', '2025-02-20 13:40:00', 80.00, 1),
(3, 8, '2025-02-20 15:30:00', '2025-02-20 16:10:00', 85.00, 1),
(3, 9, '2025-02-20 17:00:00', '2025-02-20 17:42:00', 70.00, 1),

-- Psychological Theories Quiz attempts
(5, 7, '2025-02-10 09:30:00', '2025-02-10 09:55:00', 90.00, 1),
(5, 8, '2025-02-10 10:15:00', '2025-02-10 10:42:00', 80.00, 1),
(5, 10, '2025-02-10 14:00:00', '2025-02-10 14:28:00', 95.00, 1),
(5, 13, '2025-02-10 16:30:00', '2025-02-10 16:58:00', 85.00, 1);

-- ======== STUDENT ANSWERS INSERTION ========
-- Insert Student Answers
INSERT INTO StudentAnswers (AttemptID, QuestionID, SelectedOptionID, TextAnswer, IsCorrect, PointsEarned)
VALUES
-- John Smith's answers to Programming Quiz
(1, 1, 1, NULL, 1, 5.00),
(1, 2, 8, NULL, 1, 5.00),
(1, 3, 10, NULL, 1, 5.00),
(1, 4, NULL, 'A loop is a programming structure that repeats a sequence of instructions until a specific condition is met. Example: for i in range(10): print(i)', 0, 8.50),

-- Emily Jones's answers to Programming Quiz
(2, 1, 1, NULL, 1, 5.00),
(2, 2, 8, NULL, 1, 5.00),
(2, 3, 10, NULL, 1, 5.00),
(2, 4, NULL, 'A loop is a control flow statement that allows code to be executed repeatedly based on a condition. Examples include for loops and while loops.', 1, 10.00),

-- Emily Jones's answers to Calculus Quiz
(5, 9, 10, NULL, 1, 5.00),
(5, 10, 13, NULL, 1, 5.00),
(5, 11, 15, NULL, 1, 5.00),
(5, 12, NULL, 'A limit describes the behavior of a function as its input approaches a certain value. Example: lim(x→0) sin(x)/x = 1', 1, 10.00),

-- Sarah Brown's answers to Psychological Theories Quiz
(8, 17, 21, NULL, 1, 5.00),
(8, 18, 26, NULL, 1, 5.00),
(8, 19, 28, NULL, 1, 5.00),
(8, 20, NULL, 'Classical conditioning involves associating an involuntary response with a stimulus, while operant conditioning involves associating behaviors with consequences.', 1, 10.00);

-- ======== ASSIGNMENTS INSERTION ========
-- Insert Assignments
INSERT INTO Assignments (CourseID, AssignmentTitle, Description, DueDate, TotalPoints, CreatedByUserID, CreationDate, IsActive)
VALUES
(1, 'Python Programming Project', 'Create a simple calculator application using Python.', '2025-03-01', 100, 1, '2025-01-25', 1),
(1, 'Algorithm Analysis Paper', 'Write a paper analyzing the efficiency of sorting algorithms.', '2025-04-01', 100, 1, '2025-01-30', 1),
(2, 'Calculus Problem Set', 'Complete the problem set on derivatives and integrals.', '2025-03-05', 50, 2, '2025-01-28', 1),
(3, 'Business Proposal Writing', 'Write a business proposal for a fictional product launch.', '2025-03-10', 100, 3, '2025-01-27', 1),
(4, 'Psychology Research Summary', 'Summarize a recent research article in psychology.', '2025-03-15', 75, 1, '2025-01-26', 1),
(5, 'Data Analysis Project', 'Analyze the provided dataset and create visualizations.', '2025-03-20', 100, 2, '2025-01-29', 1);

-- ======== ASSIGNMENT SUBMISSIONS INSERTION ========
INSERT INTO AssignmentSubmissions (AssignmentID, StudentID, SubmissionDate, FilePath, Comments, Grade, GradedByUserID, GradedDate)
VALUES
-- Python Programming Project submissions
(1, 4, '2025-02-28 15:30:00', '/submissions/smith_calculator.py', 'Implemented all required functionality.', 92.5, 1, '2025-03-03'),
(1, 5, '2025-02-27 10:15:00', '/submissions/jones_calculator.py', 'Great work! Included additional features.', 98.0, 1, '2025-03-03'),
(1, 6, '2025-02-28 23:45:00', '/submissions/wilson_calculator.py', 'Basic implementation, some bugs.', 85.0, 1, '2025-03-03'),
(1, 7, '2025-02-26 14:20:00', '/submissions/brown_calculator.py', 'Excellent implementation with error handling.', 95.0, 1, '2025-03-02'),

-- Calculus Problem Set submissions
(3, 5, '2025-03-04 18:30:00', '/submissions/jones_calculus.pdf', 'All problems solved correctly.', 48.0, 2, '2025-03-06'),
(3, 8, '2025-03-05 09:45:00', '/submissions/taylor_calculus.pdf', 'Good work with minor calculation errors.', 45.0, 2, '2025-03-06'),
(3, 9, '2025-03-04 22:10:00', '/submissions/miller_calculus.pdf', 'Several errors in integration problems.', 38.0, 2, '2025-03-06'),

-- Business Proposal Writing submissions
(4, 4, '2025-03-09 16:20:00', '/submissions/smith_proposal.docx', 'Well-structured proposal with strong arguments.', 90.0, 3, '2025-03-12'),
(4, 6, '2025-03-10 10:05:00', '/submissions/wilson_proposal.docx', 'Good content but needs better organization.', 85.0, 3, '2025-03-12'),
(4, 10, '2025-03-08 14:30:00', '/submissions/anderson_proposal.docx', 'Excellent proposal with detailed analysis.', 95.0, 3, '2025-03-11'),
(4, 11, '2025-03-10 09:55:00', '/submissions/thomas_proposal.docx', 'Decent proposal but lacks market analysis.', 80.0, 3, '2025-03-12');

-- ======== NOTIFICATIONS INSERTION ========
-- Insert Notifications
INSERT INTO Notifications (UserID, NotificationType, NotificationContent, RelatedEntityID, CreatedDate, IsRead)
VALUES
(4, 'Assignment_Graded', 'Your Python Programming Project has been graded.', 1, '2025-03-03 15:05:00', 1),
(5, 'Assignment_Graded', 'Your Python Programming Project has been graded.', 1, '2025-03-03 15:10:00', 1),
(5, 'Assignment_Graded', 'Your Calculus Problem Set has been graded.', 3, '2025-03-06 14:00:00', 0),
(4, 'New_Message', 'You have a new message from Robert Johnson.', 1, '2025-03-03 15:00:00', 1),
(5, 'New_Message', 'You have a new message from Susan Williams.', 5, '2025-03-07 10:30:00', 1),
(6, 'Assignment_Graded', 'Your Business Proposal Writing has been graded.', 4, '2025-03-12 10:00:00', 0),
(7, 'Assignment_Due_Soon', 'Assignment "Algorithm Analysis Paper" is due in 3 days.', 2, '2025-03-29 09:00:00', 0),
(8, 'New_Course_Material', 'New material added to Advanced Mathematics course.', 2, '2025-03-15 11:30:00', 0),
(9, 'Quiz_Available', 'A new quiz is available in Data Science Fundamentals course.', 6, '2025-02-25 10:00:00', 1);

-- ======== USER SESSIONS INSERTION ========
-- Insert User Sessions
INSERT INTO UserSessions (UserID, SessionToken, IPAddress, LoginTime, LogoutTime, IsActive)
VALUES
(1, 'token_admin_1_20250427', '192.168.1.100', '2025-04-27 08:30:00', NULL, 1),
(2, 'token_admin_2_20250426', '192.168.1.101', '2025-04-26 09:15:00', '2025-04-26 16:45:00', 0),
(3, 'token_admin_3_20250425', '192.168.1.102', '2025-04-25 10:00:00', '2025-04-25 17:30:00', 0),
(4, 'token_student_1_20250427', '192.168.1.200', '2025-04-27 10:15:00', NULL, 1),
(5, 'token_student_2_20250426', '192.168.1.201', '2025-04-26 11:30:00', '2025-04-26 15:45:00', 0),
(6, 'token_student_3_20250425', '192.168.1.202', '2025-04-25 13:00:00', '2025-04-25 16:15:00', 0),
(7, 'token_student_4_20250424', '192.168.1.203', '2025-04-24 09:45:00', '2025-04-24 14:30:00', 0),
(8, 'token_student_5_20250423', '192.168.1.204', '2025-04-23 10:30:00', '2025-04-23 16:00:00', 0),
(9, 'token_student_6_20250422', '192.168.1.205', '2025-04-22 11:15:00', '2025-04-22 17:15:00', 0);

-- ======== SYSTEM SETTINGS INSERTION ========
-- Insert System Settings
INSERT INTO SystemSettings (SettingName, SettingValue, Description, LastModifiedDate, LastModifiedByUserID)
VALUES
('MaintenanceMode', 'false', 'Flag to enable/disable system maintenance mode', '2025-01-01', 1),
('MaxFileUploadSize', '25', 'Maximum file upload size in MB', '2025-01-01', 1),
('SessionTimeout', '30', 'User session timeout in minutes', '2025-01-01', 1),
('AllowedFileTypes', 'pdf,doc,docx,ppt,pptx,xls,xlsx,txt,zip,mp4,mp3', 'Allowed file extensions for uploads', '2025-01-01', 1),
('SystemEmailAddress', 'system@lms.edu', 'System email address for notifications', '2025-01-01', 1),
('GradingScale', 'A:90-100,B:80-89,C:70-79,D:60-69,F:0-59', 'Default grading scale', '2025-01-01', 1),
('EnableStudentMessaging', 'true', 'Allow students to message each other', '2025-01-01', 1),
('DefaultLanguage', 'English', 'Default system language', '2025-01-01', 1),
('EnableNotifications', 'true', 'Enable system notifications', '2025-01-01', 1),
('MaxLoginAttempts', '5', 'Maximum failed login attempts before account lockout', '2025-01-01', 1);