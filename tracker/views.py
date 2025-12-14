from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from rest_framework.authtoken.models import Token
from rest_framework.pagination import PageNumberPagination
from django.shortcuts import get_object_or_404
from django.db.models import Q
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend

from .models import (
    Institution, Department, Course, Skill, Student, Organization,
    TrainingOpportunity, Application, ApplicationStatusHistory, Notification,
    SystemConfig, Review
)
from .serializers import (
    InstitutionSerializer, DepartmentSerializer, CourseSerializer, SkillSerializer,
    StudentListSerializer, StudentDetailSerializer, OrganizationListSerializer,
    OrganizationDetailSerializer, TrainingOpportunityListSerializer,
    TrainingOpportunityDetailSerializer, ApplicationListSerializer,
    ApplicationDetailSerializer, NotificationSerializer, ReviewSerializer,
    StudentRegistrationSerializer, OrganizationRegistrationSerializer,
    UserDetailSerializer
)
from .matching import SmartMatcher


# ============================================================================
# AUTHENTICATION ENDPOINTS
# ============================================================================

@api_view(['POST'])
@permission_classes([AllowAny])
def student_register(request):
    """Register a new student"""
    serializer = StudentRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        student = serializer.save()
        user = student.user
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserDetailSerializer(user).data,
            'student': StudentDetailSerializer(student).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def organization_register(request):
    """Register a new organization"""
    serializer = OrganizationRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        org = serializer.save()
        user = org.user
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserDetailSerializer(user).data,
            'organization': OrganizationDetailSerializer(org).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login endpoint - returns auth token"""
    username = request.data.get('username')
    password = request.data.get('password')
    
    from django.contrib.auth import authenticate
    user = authenticate(username=username, password=password)
    
    if user:
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserDetailSerializer(user).data
        })
    return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    """Get current user profile"""
    user = request.user
    data = UserDetailSerializer(user).data
    
    # Add student or organization info
    if hasattr(user, 'student_profile'):
        data['type'] = 'student'
        data['profile'] = StudentDetailSerializer(user.student_profile).data
    elif hasattr(user, 'organization_profile'):
        data['type'] = 'organization'
        data['profile'] = OrganizationDetailSerializer(user.organization_profile).data
    
    return Response(data)


# ============================================================================
# INSTITUTION VIEWSETS
# ============================================================================

class InstitutionViewSet(viewsets.ModelViewSet):
    queryset = Institution.objects.filter(is_active=True)
    serializer_class = InstitutionSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'location']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]


class DepartmentViewSet(viewsets.ModelViewSet):
    queryset = Department.objects.filter(is_active=True)
    serializer_class = DepartmentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['institution']
    search_fields = ['name']
    ordering_fields = ['name']
    ordering = ['name']
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]


# ============================================================================
# COURSE & SKILL VIEWSETS
# ============================================================================

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.filter(is_active=True)
    serializer_class = CourseSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['department', 'level']
    search_fields = ['name', 'code']
    ordering_fields = ['name', 'level']
    ordering = ['name']
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]


class SkillViewSet(viewsets.ModelViewSet):
    queryset = Skill.objects.filter(is_active=True)
    serializer_class = SkillSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'category']
    ordering_fields = ['name', 'category']
    ordering = ['name']
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]


# ============================================================================
# STUDENT VIEWSETS
# ============================================================================

class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['institution', 'course', 'academic_level', 'is_placed']
    search_fields = ['user__first_name', 'user__last_name', 'registration_number', 'user__email']
    ordering_fields = ['registered_at', 'is_placed', 'placement_date']
    ordering = ['-registered_at']
    pagination_class = PageNumberPagination
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return StudentDetailSerializer
        return StudentListSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_profile(self, request):
        """Get current student's profile"""
        try:
            student = request.user.student_profile
            serializer = StudentDetailSerializer(student)
            return Response(serializer.data)
        except Student.DoesNotExist:
            return Response({'error': 'Not a student'}, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def update_skills(self, request, pk=None):
        """Update student skills"""
        student = self.get_object()
        skill_ids = request.data.get('skill_ids', [])
        skills = Skill.objects.filter(id__in=skill_ids)
        student.skills.set(skills)
        return Response(StudentDetailSerializer(student).data)


# ============================================================================
# ORGANIZATION VIEWSETS
# ============================================================================

class OrganizationViewSet(viewsets.ModelViewSet):
    queryset = Organization.objects.filter(is_active=True)
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_verified', 'industry_type']
    search_fields = ['name', 'industry_type', 'location']
    ordering_fields = ['rating', 'name', 'created_at']
    ordering = ['-rating', 'name']
    pagination_class = PageNumberPagination
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return OrganizationDetailSerializer
        return OrganizationListSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_profile(self, request):
        """Get current organization's profile"""
        try:
            org = request.user.organization_profile
            serializer = OrganizationDetailSerializer(org)
            return Response(serializer.data)
        except Organization.DoesNotExist:
            return Response({'error': 'Not an organization'}, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# TRAINING OPPORTUNITY VIEWSETS
# ============================================================================

class TrainingOpportunityViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['organization', 'is_open', 'supported_levels']
    search_fields = ['title', 'description', 'organization__name']
    ordering_fields = ['posted_at', 'deadline', 'remaining_slots']
    ordering = ['-posted_at']
    pagination_class = PageNumberPagination
    
    def get_queryset(self):
        queryset = TrainingOpportunity.objects.filter(is_active=True)
        
        # Filter by course if specified
        courses = self.request.query_params.getlist('courses')
        if courses:
            queryset = queryset.filter(supported_courses__id__in=courses).distinct()
        
        # Filter by open slots only if specified
        if self.request.query_params.get('available_only') == 'true':
            queryset = queryset.filter(remaining_slots__gt=0, is_open=True)
        
        return queryset
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return TrainingOpportunityDetailSerializer
        return TrainingOpportunityListSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_opportunities(self, request):
        """Get organization's training opportunities"""
        try:
            org = request.user.organization_profile
            opportunities = org.training_opportunities.all()
            serializer = TrainingOpportunityListSerializer(opportunities, many=True)
            return Response(serializer.data)
        except Organization.DoesNotExist:
            return Response({'error': 'Not an organization'}, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def matched_opportunities(self, request):
        """Get matched training opportunities for a student"""
        try:
            student = request.user.student_profile
            matcher = SmartMatcher()
            matched = matcher.find_matched_opportunities(student)
            
            # Sort by match score
            opportunities_with_scores = sorted(
                matched.items(),
                key=lambda x: x[1]['match_score'],
                reverse=True
            )
            
            data = []
            for opp, score_info in opportunities_with_scores:
                opp_data = TrainingOpportunityDetailSerializer(opp).data
                opp_data['match_score'] = score_info['match_score']
                opp_data['match_quality'] = score_info['match_quality']
                opp_data['match_details'] = score_info['match_details']
                data.append(opp_data)
            
            return Response(data)
        except Student.DoesNotExist:
            return Response({'error': 'Not a student'}, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# APPLICATION VIEWSETS
# ============================================================================

class ApplicationViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['student', 'organization', 'status']
    search_fields = ['student__user__first_name', 'student__user__last_name', 'organization__name']
    ordering_fields = ['applied_at', 'match_score', 'status']
    ordering = ['-applied_at']
    pagination_class = PageNumberPagination
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Application.objects.all()
        elif hasattr(user, 'student_profile'):
            return Application.objects.filter(student=user.student_profile)
        elif hasattr(user, 'organization_profile'):
            return Application.objects.filter(organization=user.organization_profile)
        return Application.objects.none()
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ApplicationDetailSerializer
        return ApplicationListSerializer
    
    def get_permissions(self):
        return [IsAuthenticated()]
    
    def create(self, request, *args, **kwargs):
        """Submit an application"""
        try:
            student = request.user.student_profile
        except Student.DoesNotExist:
            return Response({'error': 'Only students can apply'}, status=status.HTTP_400_BAD_REQUEST)
        
        training_opportunity_id = request.data.get('training_opportunity_id')
        try:
            opp = TrainingOpportunity.objects.get(id=training_opportunity_id, is_open=True)
        except TrainingOpportunity.DoesNotExist:
            return Response({'error': 'Training opportunity not found or closed'}, status=status.HTTP_404_NOT_FOUND)
        
        # Check if already applied
        if Application.objects.filter(student=student, training_opportunity=opp).exists():
            return Response({'error': 'Already applied to this opportunity'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Calculate match score
        matcher = SmartMatcher()
        match_info = matcher.calculate_match_score(student, opp)
        
        # Create application
        application = Application.objects.create(
            student=student,
            training_opportunity=opp,
            organization=opp.organization,
            match_score=match_info['match_score'],
            match_quality=match_info['match_quality'],
            match_details=match_info['match_details']
        )
        
        # Create notification for organization
        Notification.objects.create(
            user=opp.organization.user,
            notification_type='application_received',
            title=f'New Application: {student.full_name}',
            message=f'{student.full_name} applied for {opp.title} (Match: {application.match_score}%)',
            application=application
        )
        
        return Response(ApplicationDetailSerializer(application).data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def accept(self, request, pk=None):
        """Accept an application"""
        application = self.get_object()
        
        # Check permission
        try:
            org = request.user.organization_profile
            if application.organization != org:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        except Organization.DoesNotExist:
            return Response({'error': 'Only organizations can accept applications'}, status=status.HTTP_400_BAD_REQUEST)
        
        acceptance_letter = request.data.get('acceptance_letter', '')
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')
        
        application.accept(acceptance_letter, start_date, end_date)
        
        # Create notification
        Notification.objects.create(
            user=application.student.user,
            notification_type='application_accepted',
            title='Application Accepted!',
            message=f'Your application for {application.training_opportunity.title} has been accepted!',
            application=application
        )
        
        # Create status history
        ApplicationStatusHistory.objects.create(
            application=application,
            old_status='pending',
            new_status='accepted',
            changed_by=request.user,
            notes=acceptance_letter
        )
        
        return Response(ApplicationDetailSerializer(application).data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def reject(self, request, pk=None):
        """Reject an application"""
        application = self.get_object()
        
        # Check permission
        try:
            org = request.user.organization_profile
            if application.organization != org:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        except Organization.DoesNotExist:
            return Response({'error': 'Only organizations can reject applications'}, status=status.HTTP_400_BAD_REQUEST)
        
        reason = request.data.get('reason', '')
        application.reject(reason)
        
        # Create notification
        Notification.objects.create(
            user=application.student.user,
            notification_type='application_rejected',
            title='Application Update',
            message=f'Your application for {application.training_opportunity.title} was not selected.',
            application=application
        )
        
        # Create status history
        ApplicationStatusHistory.objects.create(
            application=application,
            old_status='pending',
            new_status='rejected',
            changed_by=request.user,
            notes=reason
        )
        
        return Response(ApplicationDetailSerializer(application).data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def withdraw(self, request, pk=None):
        """Withdraw an application"""
        application = self.get_object()
        
        # Check permission
        if application.student.user != request.user:
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        application.withdraw()
        
        # Create notification
        Notification.objects.create(
            user=application.organization.user,
            notification_type='application_rejected',
            title='Application Withdrawn',
            message=f'{application.student.full_name} withdrew their application for {application.training_opportunity.title}',
            application=application
        )
        
        # Create status history
        ApplicationStatusHistory.objects.create(
            application=application,
            old_status='pending',
            new_status='withdrawn',
            changed_by=request.user
        )
        
        return Response(ApplicationDetailSerializer(application).data)


# ============================================================================
# NOTIFICATION VIEWSETS
# ============================================================================

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NotificationSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['is_read']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    pagination_class = PageNumberPagination
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.mark_as_read()
        return Response(NotificationSerializer(notification).data)
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """Mark all notifications as read"""
        Notification.objects.filter(user=request.user, is_read=False).update(
            is_read=True,
            read_at=timezone.now()
        )
        return Response({'status': 'All notifications marked as read'})


# ============================================================================
# REVIEW VIEWSETS
# ============================================================================

class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['organization', 'rating']
    ordering_fields = ['rating', 'created_at']
    ordering = ['-created_at']
    pagination_class = PageNumberPagination
    
    def get_queryset(self):
        return Review.objects.filter(is_verified=True)
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        elif self.action == 'create':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def create(self, request, *args, **kwargs):
        """Submit a review"""
        try:
            student = request.user.student_profile
        except Student.DoesNotExist:
            return Response({'error': 'Only students can leave reviews'}, status=status.HTTP_400_BAD_REQUEST)
        
        organization_id = request.data.get('organization_id')
        
        # Check if student was placed at the organization
        application = Application.objects.filter(
            student=student,
            organization_id=organization_id,
            status='completed'
        ).first()
        
        if not application:
            return Response(
                {'error': 'Can only review organizations you completed training with'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        review_data = request.data.copy()
        review_data['student'] = student.id
        review_data['organization'] = organization_id
        review_data['application'] = application.id
        
        serializer = self.get_serializer(data=review_data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)
