from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    Institution, Department, Course, Skill, Student, Organization,
    TrainingOpportunity, Application, ApplicationStatusHistory, Notification,
    SystemConfig, Review
)


# ============================================================================
# USER SERIALIZERS
# ============================================================================

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')
        read_only_fields = ('id',)


class UserDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'is_staff', 'is_active', 'date_joined')
        read_only_fields = ('id', 'date_joined')


# ============================================================================
# INSTITUTION & DEPARTMENT SERIALIZERS
# ============================================================================

class InstitutionSerializer(serializers.ModelSerializer):
    department_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Institution
        fields = ('id', 'name', 'institution_type', 'location', 'description', 'phone', 'email', 'website', 'is_active', 'department_count')
        read_only_fields = ('id',)
    
    def get_department_count(self, obj):
        return obj.departments.filter(is_active=True).count()


class DepartmentSerializer(serializers.ModelSerializer):
    institution_name = serializers.CharField(source='institution.name', read_only=True)
    
    class Meta:
        model = Department
        fields = ('id', 'institution', 'institution_name', 'name', 'description', 'head_of_department', 'is_active')
        read_only_fields = ('id',)


# ============================================================================
# COURSE & SKILL SERIALIZERS
# ============================================================================

class CourseSerializer(serializers.ModelSerializer):
    department_name = serializers.CharField(source='department.name', read_only=True)
    
    class Meta:
        model = Course
        fields = ('id', 'name', 'code', 'department', 'department_name', 'level', 'description', 'duration_months', 'is_active')
        read_only_fields = ('id',)


class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ('id', 'name', 'category', 'description', 'is_active')
        read_only_fields = ('id',)


# ============================================================================
# STUDENT SERIALIZERS
# ============================================================================

class StudentListSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='user.get_full_name', read_only=True)
    email = serializers.CharField(source='user.email', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    institution_name = serializers.CharField(source='institution.name', read_only=True)
    skill_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Student
        fields = (
            'id', 'user', 'full_name', 'email', 'registration_number', 'institution',
            'institution_name', 'course', 'course_name', 'academic_level', 'phone',
            'preferred_location', 'is_placed', 'placement_date', 'skill_count'
        )
        read_only_fields = ('id', 'user', 'placement_date')
    
    def get_skill_count(self, obj):
        return obj.skills.count()


class StudentDetailSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='user.get_full_name', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    institution_name = serializers.CharField(source='institution.name', read_only=True)
    department_name = serializers.CharField(source='department.name', read_only=True)
    skills = SkillSerializer(many=True, read_only=True)
    skill_ids = serializers.PrimaryKeyRelatedField(
        queryset=Skill.objects.all(),
        write_only=True,
        many=True,
        source='skills'
    )
    
    class Meta:
        model = Student
        fields = (
            'id', 'user', 'username', 'full_name', 'email', 'registration_number',
            'institution', 'institution_name', 'department', 'department_name',
            'course', 'course_name', 'academic_level', 'phone', 'profile_photo',
            'bio', 'preferred_location', 'skills', 'skill_ids', 'is_active',
            'is_placed', 'placement_date', 'registered_at', 'updated_at'
        )
        read_only_fields = ('id', 'user', 'registered_at', 'updated_at', 'placement_date')


# ============================================================================
# ORGANIZATION SERIALIZERS
# ============================================================================

class OrganizationListSerializer(serializers.ModelSerializer):
    contact_person = serializers.CharField(source='user.get_full_name', read_only=True)
    email = serializers.CharField(source='user.email', read_only=True)
    course_count = serializers.SerializerMethodField()
    opportunity_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Organization
        fields = (
            'id', 'user', 'name', 'industry_type', 'location', 'phone', 'email',
            'contact_person', 'is_verified', 'is_active', 'rating', 'review_count',
            'course_count', 'opportunity_count'
        )
        read_only_fields = ('id', 'user', 'rating', 'review_count')
    
    def get_course_count(self, obj):
        return obj.supported_courses.count()
    
    def get_opportunity_count(self, obj):
        return obj.training_opportunities.filter(is_active=True).count()


class OrganizationDetailSerializer(serializers.ModelSerializer):
    contact_person = serializers.CharField(source='user.get_full_name', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    supported_courses = CourseSerializer(many=True, read_only=True)
    course_ids = serializers.PrimaryKeyRelatedField(
        queryset=Course.objects.all(),
        write_only=True,
        many=True,
        source='supported_courses'
    )
    required_skills = SkillSerializer(many=True, read_only=True)
    skill_ids = serializers.PrimaryKeyRelatedField(
        queryset=Skill.objects.all(),
        write_only=True,
        many=True,
        source='required_skills'
    )
    
    class Meta:
        model = Organization
        fields = (
            'id', 'user', 'username', 'name', 'industry_type', 'location',
            'description', 'phone', 'email', 'website', 'logo', 'contact_person',
            'supported_courses', 'course_ids', 'required_skills', 'skill_ids',
            'is_verified', 'verified_at', 'is_active', 'rating', 'review_count',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'user', 'rating', 'review_count', 'verified_at', 'created_at', 'updated_at')


# ============================================================================
# TRAINING OPPORTUNITY SERIALIZERS
# ============================================================================

class TrainingOpportunityListSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    slots_filled = serializers.SerializerMethodField()
    
    class Meta:
        model = TrainingOpportunity
        fields = (
            'id', 'organization', 'organization_name', 'title', 'total_slots',
            'remaining_slots', 'slots_filled', 'training_duration_months',
            'deadline', 'is_open', 'posted_at'
        )
        read_only_fields = ('id', 'posted_at')
    
    def get_slots_filled(self, obj):
        return obj.slots_filled


class TrainingOpportunityDetailSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    organization_detail = OrganizationListSerializer(source='organization', read_only=True)
    supported_courses = CourseSerializer(many=True, read_only=True)
    course_ids = serializers.PrimaryKeyRelatedField(
        queryset=Course.objects.all(),
        write_only=True,
        many=True,
        source='supported_courses'
    )
    required_skills = SkillSerializer(many=True, read_only=True)
    skill_ids = serializers.PrimaryKeyRelatedField(
        queryset=Skill.objects.all(),
        write_only=True,
        many=True,
        source='required_skills'
    )
    slots_filled = serializers.SerializerMethodField()
    
    class Meta:
        model = TrainingOpportunity
        fields = (
            'id', 'organization', 'organization_name', 'organization_detail',
            'title', 'description', 'total_slots', 'remaining_slots', 'slots_filled',
            'training_duration_months', 'minimum_gpa', 'required_skills', 'skill_ids',
            'supported_courses', 'course_ids', 'supported_levels', 'deadline',
            'is_active', 'is_open', 'posted_at', 'updated_at'
        )
        read_only_fields = ('id', 'posted_at', 'updated_at')
    
    def get_slots_filled(self, obj):
        return obj.slots_filled


# ============================================================================
# APPLICATION SERIALIZERS
# ============================================================================

class ApplicationStatusHistorySerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source='changed_by.get_full_name', read_only=True)
    
    class Meta:
        model = ApplicationStatusHistory
        fields = ('id', 'old_status', 'new_status', 'changed_by', 'changed_by_name', 'notes', 'changed_at')
        read_only_fields = ('id', 'changed_at')


class ApplicationListSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.full_name', read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    opportunity_title = serializers.CharField(source='training_opportunity.title', read_only=True)
    
    class Meta:
        model = Application
        fields = (
            'id', 'student', 'student_name', 'organization', 'organization_name',
            'training_opportunity', 'opportunity_title', 'match_score', 'match_quality',
            'status', 'applied_at', 'responded_at'
        )
        read_only_fields = ('id', 'applied_at', 'responded_at')


class ApplicationDetailSerializer(serializers.ModelSerializer):
    student_detail = StudentListSerializer(source='student', read_only=True)
    organization_detail = OrganizationListSerializer(source='organization', read_only=True)
    opportunity_detail = TrainingOpportunityListSerializer(source='training_opportunity', read_only=True)
    status_history = ApplicationStatusHistorySerializer(many=True, read_only=True)
    
    class Meta:
        model = Application
        fields = (
            'id', 'student', 'student_detail', 'organization', 'organization_detail',
            'training_opportunity', 'opportunity_detail', 'match_score', 'match_quality',
            'match_details', 'status', 'applied_at', 'responded_at', 'acceptance_letter',
            'rejection_reason', 'start_date', 'end_date', 'status_history',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'match_score', 'match_quality', 'match_details', 'applied_at', 'responded_at', 'created_at', 'updated_at')


# ============================================================================
# NOTIFICATION SERIALIZERS
# ============================================================================

class NotificationSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    
    class Meta:
        model = Notification
        fields = (
            'id', 'user', 'user_name', 'notification_type', 'title', 'message',
            'application', 'training_opportunity', 'is_read', 'created_at', 'read_at'
        )
        read_only_fields = ('id', 'user', 'created_at', 'read_at')


# ============================================================================
# REVIEW SERIALIZERS
# ============================================================================

class ReviewSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.full_name', read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    
    class Meta:
        model = Review
        fields = (
            'id', 'student', 'student_name', 'organization', 'organization_name',
            'rating', 'title', 'comment', 'is_verified', 'created_at'
        )
        read_only_fields = ('id', 'created_at', 'is_verified')


# ============================================================================
# AUTHENTICATION SERIALIZERS
# ============================================================================

class StudentRegistrationSerializer(serializers.Serializer):
    """Serializer for student registration"""
    username = serializers.CharField(max_length=150, required=True)
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True, min_length=8)
    password2 = serializers.CharField(write_only=True, required=True, min_length=8)
    first_name = serializers.CharField(max_length=150, required=True)
    last_name = serializers.CharField(max_length=150, required=True)
    registration_number = serializers.CharField(max_length=50, required=True)
    institution = serializers.PrimaryKeyRelatedField(queryset=Institution.objects.all())
    course = serializers.PrimaryKeyRelatedField(queryset=Course.objects.all())
    academic_level = serializers.CharField(max_length=20)
    phone = serializers.CharField(max_length=20)
    preferred_location = serializers.CharField(max_length=255, required=False)
    
    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords do not match"})
        if User.objects.filter(username=data['username']).exists():
            raise serializers.ValidationError({"username": "Username already exists"})
        if User.objects.filter(email=data['email']).exists():
            raise serializers.ValidationError({"email": "Email already exists"})
        return data
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name']
        )
        
        student = Student.objects.create(
            user=user,
            registration_number=validated_data['registration_number'],
            institution=validated_data['institution'],
            course=validated_data['course'],
            academic_level=validated_data['academic_level'],
            phone=validated_data['phone'],
            preferred_location=validated_data.get('preferred_location', '')
        )
        
        return student


class OrganizationRegistrationSerializer(serializers.Serializer):
    """Serializer for organization registration"""
    username = serializers.CharField(max_length=150, required=True)
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True, min_length=8)
    password2 = serializers.CharField(write_only=True, required=True, min_length=8)
    name = serializers.CharField(max_length=255, required=True)
    industry_type = serializers.CharField(max_length=100, required=True)
    location = serializers.CharField(max_length=255, required=True)
    description = serializers.CharField(required=True)
    phone = serializers.CharField(max_length=20, required=True)
    website = serializers.URLField(required=False)
    
    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords do not match"})
        if User.objects.filter(username=data['username']).exists():
            raise serializers.ValidationError({"username": "Username already exists"})
        if User.objects.filter(email=data['email']).exists():
            raise serializers.ValidationError({"email": "Email already exists"})
        if Organization.objects.filter(name=data['name']).exists():
            raise serializers.ValidationError({"name": "Organization name already exists"})
        return data
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        
        organization = Organization.objects.create(
            user=user,
            name=validated_data['name'],
            industry_type=validated_data['industry_type'],
            location=validated_data['location'],
            description=validated_data['description'],
            phone=validated_data['phone'],
            email=validated_data['email'],
            website=validated_data.get('website', '')
        )
        
        return organization
