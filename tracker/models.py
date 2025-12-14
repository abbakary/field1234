from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

# ============================================================================
# INSTITUTIONS & DEPARTMENTS
# ============================================================================

class Institution(models.Model):
    """Higher learning institutions in Tanzania"""
    INSTITUTION_TYPES = (
        ('university', 'University'),
        ('college', 'College'),
        ('technical', 'Technical Institute'),
    )
    
    name = models.CharField(max_length=255, unique=True)
    institution_type = models.CharField(max_length=20, choices=INSTITUTION_TYPES)
    location = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    website = models.URLField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "Institutions"
        ordering = ['name']
    
    def __str__(self):
        return self.name


class Department(models.Model):
    """Departments within institutions"""
    institution = models.ForeignKey(Institution, on_delete=models.CASCADE, related_name='departments')
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    head_of_department = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('institution', 'name')
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} - {self.institution.name}"


# ============================================================================
# COURSES & SKILLS
# ============================================================================

class Course(models.Model):
    """Academic courses/programs"""
    ACADEMIC_LEVELS = (
        ('diploma', 'Diploma'),
        ('degree', 'Bachelor Degree'),
        ('masters', 'Masters'),
    )
    
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=50, unique=True)
    department = models.ForeignKey(Department, on_delete=models.CASCADE, related_name='courses')
    level = models.CharField(max_length=20, choices=ACADEMIC_LEVELS)
    description = models.TextField(blank=True)
    duration_months = models.PositiveIntegerField(default=36, help_text="Course duration in months")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('code', 'level')
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.level.title()})"


class Skill(models.Model):
    """Technical and soft skills"""
    SKILL_CATEGORIES = (
        ('technical', 'Technical'),
        ('soft', 'Soft Skills'),
        ('language', 'Language'),
        ('management', 'Management'),
    )
    
    name = models.CharField(max_length=100, unique=True)
    category = models.CharField(max_length=20, choices=SKILL_CATEGORIES)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.name


# ============================================================================
# STUDENT & PROFILE
# ============================================================================

class Student(models.Model):
    """Student profile for industrial training"""
    ACADEMIC_LEVELS = (
        ('diploma', 'Diploma'),
        ('degree', 'Bachelor Degree'),
        ('masters', 'Masters'),
    )
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    registration_number = models.CharField(max_length=50, unique=True)
    institution = models.ForeignKey(Institution, on_delete=models.SET_NULL, null=True)
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    course = models.ForeignKey(Course, on_delete=models.SET_NULL, null=True)
    academic_level = models.CharField(max_length=20, choices=ACADEMIC_LEVELS)
    
    # Profile information
    phone = models.CharField(max_length=20)
    profile_photo = models.ImageField(upload_to='student_profiles/', blank=True, null=True)
    bio = models.TextField(blank=True)
    preferred_location = models.CharField(max_length=255, blank=True)
    
    # Skills
    skills = models.ManyToManyField(Skill, blank=True, related_name='students')
    
    # Status
    is_active = models.BooleanField(default=True)
    is_placed = models.BooleanField(default=False)
    placement_date = models.DateField(blank=True, null=True)
    
    # Timestamps
    registered_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-registered_at']
    
    def __str__(self):
        return f"{self.user.get_full_name()} ({self.registration_number})"
    
    @property
    def full_name(self):
        return self.user.get_full_name() or self.user.username
    
    @property
    def email(self):
        return self.user.email


# ============================================================================
# ORGANIZATION & TRAINING OPPORTUNITIES
# ============================================================================

class Organization(models.Model):
    """Partner organizations offering training"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='organization_profile')
    name = models.CharField(max_length=255, unique=True)
    industry_type = models.CharField(max_length=100)
    location = models.CharField(max_length=255)
    description = models.TextField()
    
    # Contact information
    phone = models.CharField(max_length=20)
    email = models.EmailField()
    website = models.URLField(blank=True)
    
    # Logo/branding
    logo = models.ImageField(upload_to='organization_logos/', blank=True, null=True)
    
    # Requirements & supported courses
    supported_courses = models.ManyToManyField(Course, related_name='organizations')
    supported_levels = models.ManyToManyField(Course, through='OrganizationCourseLevel', related_name='+')
    required_skills = models.ManyToManyField(Skill, related_name='organizations_requiring_skill')
    
    # Verification
    is_verified = models.BooleanField(default=False)
    verified_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='verified_organizations')
    verified_at = models.DateTimeField(blank=True, null=True)
    
    # Status
    is_active = models.BooleanField(default=True)
    
    # Ratings (auto-calculated)
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=0)
    review_count = models.PositiveIntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-rating', 'name']
    
    def __str__(self):
        return self.name


class OrganizationCourseLevel(models.Model):
    """Many-to-many through model for organization course levels"""
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    
    class Meta:
        unique_together = ('organization', 'course')


class TrainingOpportunity(models.Model):
    """Specific training opportunities posted by organizations"""
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, related_name='training_opportunities')
    title = models.CharField(max_length=255)
    description = models.TextField()
    
    # Capacity & Duration
    total_slots = models.PositiveIntegerField(validators=[MinValueValidator(1)])
    remaining_slots = models.PositiveIntegerField(validators=[MinValueValidator(0)])
    training_duration_months = models.PositiveIntegerField(default=3)
    
    # Requirements
    minimum_gpa = models.DecimalField(max_digits=3, decimal_places=2, default=2.0, blank=True)
    required_skills = models.ManyToManyField(Skill, blank=True)
    supported_courses = models.ManyToManyField(Course)
    supported_levels = models.CharField(
        max_length=50,
        choices=(('diploma', 'Diploma'), ('degree', 'Degree'), ('both', 'Both')),
        default='both'
    )
    
    # Application deadline
    deadline = models.DateTimeField()
    
    # Status
    is_active = models.BooleanField(default=True)
    is_open = models.BooleanField(default=True)
    
    # Timestamps
    posted_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-posted_at']
    
    def __str__(self):
        return f"{self.title} - {self.organization.name}"
    
    @property
    def slots_filled(self):
        return self.total_slots - self.remaining_slots
    
    def close_if_full(self):
        """Auto-close opportunity when slots are full"""
        if self.remaining_slots <= 0:
            self.is_open = False
            self.save()


# ============================================================================
# APPLICATION & MATCHING
# ============================================================================

class Application(models.Model):
    """Student application to training opportunities"""
    APPLICATION_STATUS = (
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
        ('withdrawn', 'Withdrawn'),
        ('completed', 'Completed'),
    )
    
    MATCH_QUALITY = (
        ('high', 'Highly Matched (80%+)'),
        ('medium', 'Partially Matched (60-79%)'),
        ('low', 'Low Match (below 60%)'),
        ('not_eligible', 'Not Eligible'),
    )
    
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='applications')
    training_opportunity = models.ForeignKey(TrainingOpportunity, on_delete=models.CASCADE, related_name='applications')
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, related_name='applications')
    
    # Matching information
    match_score = models.PositiveIntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    match_quality = models.CharField(max_length=20, choices=MATCH_QUALITY, default='not_eligible')
    match_details = models.JSONField(default=dict, blank=True)
    
    # Application status
    status = models.CharField(max_length=20, choices=APPLICATION_STATUS, default='pending')
    applied_at = models.DateTimeField(auto_now_add=True)
    responded_at = models.DateTimeField(blank=True, null=True)
    
    # Acceptance/Rejection details
    acceptance_letter = models.TextField(blank=True)
    rejection_reason = models.TextField(blank=True)
    
    # Training dates (once accepted)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('student', 'training_opportunity')
        ordering = ['-applied_at']
    
    def __str__(self):
        return f"{self.student.full_name} - {self.training_opportunity.title}"
    
    def accept(self, acceptance_letter="", start_date=None, end_date=None):
        """Accept the application"""
        self.status = 'accepted'
        self.acceptance_letter = acceptance_letter
        self.responded_at = timezone.now()
        if start_date:
            self.start_date = start_date
        if end_date:
            self.end_date = end_date
        self.save()
        
        # Update student placement status
        if not self.student.is_placed:
            self.student.is_placed = True
            self.student.placement_date = timezone.now().date()
            self.student.save()
        
        # Update training opportunity slots
        self.training_opportunity.remaining_slots -= 1
        self.training_opportunity.close_if_full()
    
    def reject(self, reason=""):
        """Reject the application"""
        self.status = 'rejected'
        self.rejection_reason = reason
        self.responded_at = timezone.now()
        self.save()
        
        # Return the slot to the opportunity
        self.training_opportunity.remaining_slots += 1
        if not self.training_opportunity.is_open and self.training_opportunity.remaining_slots > 0:
            self.training_opportunity.is_open = True
        self.training_opportunity.save()
    
    def withdraw(self):
        """Withdraw the application"""
        if self.status == 'pending':
            self.status = 'withdrawn'
            self.responded_at = timezone.now()
            self.save()


class ApplicationStatusHistory(models.Model):
    """Track status changes for applications"""
    application = models.ForeignKey(Application, on_delete=models.CASCADE, related_name='status_history')
    old_status = models.CharField(max_length=20)
    new_status = models.CharField(max_length=20)
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    notes = models.TextField(blank=True)
    changed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-changed_at']
    
    def __str__(self):
        return f"{self.application} - {self.old_status} → {self.new_status}"


# ============================================================================
# NOTIFICATIONS
# ============================================================================

class Notification(models.Model):
    """In-app notifications for students and organizations"""
    NOTIFICATION_TYPES = (
        ('application_received', 'Application Received'),
        ('application_accepted', 'Application Accepted'),
        ('application_rejected', 'Application Rejected'),
        ('new_opportunity', 'New Opportunity'),
        ('deadline_reminder', 'Deadline Reminder'),
        ('system_message', 'System Message'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=30, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=255)
    message = models.TextField()
    
    # Related objects
    application = models.ForeignKey(Application, on_delete=models.CASCADE, null=True, blank=True)
    training_opportunity = models.ForeignKey(TrainingOpportunity, on_delete=models.CASCADE, null=True, blank=True)
    
    # Status
    is_read = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.user.username}"
    
    def mark_as_read(self):
        """Mark notification as read"""
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save()


# ============================================================================
# SYSTEM CONFIGURATION
# ============================================================================

class SystemConfig(models.Model):
    """System configuration and settings for SITMS"""
    CONFIG_KEYS = (
        ('placement_year', 'Current Placement Year'),
        ('min_gpa', 'Minimum GPA for Placement'),
        ('application_deadline', 'Application Deadline'),
        ('max_applications_per_student', 'Max Applications Per Student'),
        ('notification_enabled', 'Enable Notifications'),
    )
    
    key = models.CharField(max_length=100, unique=True, choices=CONFIG_KEYS)
    value = models.TextField()
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "System Configuration"
    
    def __str__(self):
        return self.key


# ============================================================================
# REVIEWS & RATINGS
# ============================================================================

class Review(models.Model):
    """Student reviews for organizations"""
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='reviews')
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, related_name='reviews')
    application = models.OneToOneField(Application, on_delete=models.CASCADE, related_name='review', null=True)
    
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Rating from 1 to 5 stars"
    )
    title = models.CharField(max_length=255)
    comment = models.TextField()
    
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('student', 'organization')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.student.full_name} - {self.organization.name} ({self.rating}★)"
