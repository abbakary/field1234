from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.db.models import Q, Count
from django.utils import timezone
from .models import (
    Institution, Department, Course, Skill, Student, Organization,
    TrainingOpportunity, Application, ApplicationStatusHistory, Notification,
    SystemConfig, Review
)


# ============================================================================
# CUSTOM ADMIN ACTIONS
# ============================================================================

def mark_as_active(modeladmin, request, queryset):
    """Mark selected items as active"""
    updated = queryset.update(is_active=True)
    modeladmin.message_user(request, f'{updated} items marked as active.')
mark_as_active.short_description = 'Mark selected as active'


def mark_as_inactive(modeladmin, request, queryset):
    """Mark selected items as inactive"""
    updated = queryset.update(is_active=False)
    modeladmin.message_user(request, f'{updated} items marked as inactive.')
mark_as_inactive.short_description = 'Mark selected as inactive'


def verify_organizations(modeladmin, request, queryset):
    """Mark selected organizations as verified"""
    updated = queryset.update(is_verified=True, verified_at=timezone.now(), verified_by=request.user)
    modeladmin.message_user(request, f'{updated} organizations verified.')
verify_organizations.short_description = 'Verify selected organizations'


def unverify_organizations(modeladmin, request, queryset):
    """Mark selected organizations as unverified"""
    updated = queryset.update(is_verified=False, verified_at=None, verified_by=None)
    modeladmin.message_user(request, f'{updated} organizations unverified.')
unverify_organizations.short_description = 'Unverify selected organizations'


# ============================================================================
# INSTITUTION ADMIN
# ============================================================================

@admin.register(Institution)
class InstitutionAdmin(admin.ModelAdmin):
    list_display = ('name', 'institution_type', 'location', 'department_count', 'is_active', 'created_at')
    list_filter = ('institution_type', 'is_active', 'location', 'created_at')
    search_fields = ('name', 'location', 'email')
    readonly_fields = ('created_at', 'updated_at', 'department_count')
    actions = [mark_as_active, mark_as_inactive]
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'institution_type', 'location', 'description')
        }),
        ('Contact Information', {
            'fields': ('email', 'phone', 'website')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def department_count(self, obj):
        count = obj.departments.filter(is_active=True).count()
        return format_html(
            '<span style="background-color: #e3f2fd; padding: 3px 8px; border-radius: 3px;">{}</span>',
            count
        )
    department_count.short_description = 'Active Departments'


# ============================================================================
# DEPARTMENT ADMIN
# ============================================================================

@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ('name', 'institution', 'head_of_department', 'course_count', 'is_active')
    list_filter = ('institution', 'is_active', 'created_at')
    search_fields = ('name', 'institution__name', 'head_of_department')
    readonly_fields = ('created_at', 'updated_at', 'course_count')
    actions = [mark_as_active, mark_as_inactive]
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('institution', 'name', 'description')
        }),
        ('Management', {
            'fields': ('head_of_department',)
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def course_count(self, obj):
        count = obj.courses.filter(is_active=True).count()
        return format_html(
            '<span style="background-color: #f3e5f5; padding: 3px 8px; border-radius: 3px;">{}</span>',
            count
        )
    course_count.short_description = 'Active Courses'


# ============================================================================
# COURSE ADMIN
# ============================================================================

@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'department', 'level', 'duration_months', 'is_active')
    list_filter = ('level', 'is_active', 'department__institution', 'created_at')
    search_fields = ('name', 'code', 'department__name')
    readonly_fields = ('created_at', 'updated_at')
    actions = [mark_as_active, mark_as_inactive]
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'code', 'level', 'department')
        }),
        ('Details', {
            'fields': ('description', 'duration_months')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


# ============================================================================
# SKILL ADMIN
# ============================================================================

@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'student_count', 'is_active')
    list_filter = ('category', 'is_active', 'created_at')
    search_fields = ('name', 'category')
    readonly_fields = ('created_at', 'student_count')
    actions = [mark_as_active, mark_as_inactive]
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'category', 'description')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )
    
    def student_count(self, obj):
        count = obj.students.count()
        return format_html(
            '<span style="background-color: #e8f5e9; padding: 3px 8px; border-radius: 3px;">{}</span>',
            count
        )
    student_count.short_description = 'Students with Skill'


# ============================================================================
# APPLICATION STATUS HISTORY INLINE
# ============================================================================

class ApplicationStatusHistoryInline(admin.TabularInline):
    model = ApplicationStatusHistory
    extra = 0
    readonly_fields = ('old_status', 'new_status', 'changed_by', 'changed_at', 'notes')
    can_delete = False
    
    def has_add_permission(self, request):
        return False


# ============================================================================
# STUDENT ADMIN
# ============================================================================

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'registration_number', 'institution', 'course', 'academic_level', 'is_placed', 'registered_at')
    list_filter = ('institution', 'course', 'academic_level', 'is_placed', 'registered_at')
    search_fields = ('user__first_name', 'user__last_name', 'registration_number', 'user__email')
    readonly_fields = ('registered_at', 'updated_at', 'full_name', 'email', 'skills_display')
    actions = [mark_as_active, mark_as_inactive]
    filter_horizontal = ('skills',)
    
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'full_name', 'email')
        }),
        ('Registration Details', {
            'fields': ('registration_number', 'institution', 'course', 'academic_level')
        }),
        ('Contact Information', {
            'fields': ('phone', 'preferred_location')
        }),
        ('Profile', {
            'fields': ('profile_photo', 'bio'),
            'classes': ('collapse',)
        }),
        ('Skills', {
            'fields': ('skills', 'skills_display'),
            'classes': ('collapse',)
        }),
        ('Placement Status', {
            'fields': ('is_placed', 'placement_date', 'is_active')
        }),
        ('Timestamps', {
            'fields': ('registered_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def full_name(self, obj):
        return obj.user.get_full_name() or obj.user.username
    full_name.short_description = 'Full Name'
    
    def email(self, obj):
        return obj.user.email
    email.short_description = 'Email'
    
    def skills_display(self, obj):
        skills = obj.skills.all()
        if not skills:
            return 'No skills added'
        return format_html(
            '<div style="display: flex; flex-wrap: wrap; gap: 5px;">{}</div>',
            ''.join([
                f'<span style="background-color: #2196F3; color: white; padding: 4px 8px; border-radius: 12px; font-size: 12px;">{skill.name}</span>'
                for skill in skills
            ])
        )
    skills_display.short_description = 'Current Skills'


# ============================================================================
# ORGANIZATION ADMIN
# ============================================================================

@admin.register(Organization)
class OrganizationAdmin(admin.ModelAdmin):
    list_display = ('name', 'industry_type', 'location', 'is_verified', 'rating', 'review_count', 'opportunity_count', 'is_active')
    list_filter = ('is_verified', 'is_active', 'location', 'industry_type', 'created_at')
    search_fields = ('name', 'industry_type', 'location', 'email')
    readonly_fields = ('created_at', 'updated_at', 'verified_at', 'rating', 'review_count', 'opportunity_count')
    actions = [mark_as_active, mark_as_inactive, verify_organizations, unverify_organizations]
    filter_horizontal = ('supported_courses', 'required_skills')
    
    fieldsets = (
        ('Organization Information', {
            'fields': ('user', 'name', 'industry_type', 'location', 'description')
        }),
        ('Contact Information', {
            'fields': ('email', 'phone', 'website')
        }),
        ('Branding', {
            'fields': ('logo',),
            'classes': ('collapse',)
        }),
        ('Supported Courses & Skills', {
            'fields': ('supported_courses', 'required_skills'),
            'classes': ('collapse',)
        }),
        ('Verification', {
            'fields': ('is_verified', 'verified_by', 'verified_at')
        }),
        ('Ratings', {
            'fields': ('rating', 'review_count'),
            'classes': ('collapse',)
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def opportunity_count(self, obj):
        count = obj.training_opportunities.filter(is_active=True).count()
        return format_html(
            '<span style="background-color: #fff3e0; padding: 3px 8px; border-radius: 3px;">{}</span>',
            count
        )
    opportunity_count.short_description = 'Active Opportunities'


# ============================================================================
# TRAINING OPPORTUNITY ADMIN
# ============================================================================

@admin.register(TrainingOpportunity)
class TrainingOpportunityAdmin(admin.ModelAdmin):
    list_display = ('title', 'organization', 'total_slots', 'remaining_slots', 'deadline', 'is_open', 'is_active')
    list_filter = ('is_open', 'is_active', 'organization', 'supported_levels', 'posted_at', 'deadline')
    search_fields = ('title', 'description', 'organization__name')
    readonly_fields = ('posted_at', 'updated_at', 'slots_filled', 'application_count')
    actions = [mark_as_active, mark_as_inactive]
    filter_horizontal = ('supported_courses', 'required_skills')
    
    fieldsets = (
        ('Opportunity Information', {
            'fields': ('organization', 'title', 'description')
        }),
        ('Capacity', {
            'fields': ('total_slots', 'remaining_slots', 'slots_filled', 'training_duration_months')
        }),
        ('Requirements', {
            'fields': ('minimum_gpa', 'supported_levels', 'supported_courses', 'required_skills'),
            'classes': ('collapse',)
        }),
        ('Availability', {
            'fields': ('deadline', 'is_open', 'is_active')
        }),
        ('Status', {
            'fields': ('application_count',),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('posted_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def slots_filled(self, obj):
        filled = obj.slots_filled
        return format_html(
            '<span style="background-color: #ffcdd2; padding: 3px 8px; border-radius: 3px;">{}/{}</span>',
            filled,
            obj.total_slots
        )
    slots_filled.short_description = 'Slots Filled'
    
    def application_count(self, obj):
        count = obj.applications.count()
        return format_html(
            '<span style="background-color: #c8e6c9; padding: 3px 8px; border-radius: 3px;">{}</span>',
            count
        )
    application_count.short_description = 'Total Applications'


# ============================================================================
# APPLICATION ADMIN
# ============================================================================

@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ('student_name', 'opportunity_title', 'organization_name', 'status', 'match_quality', 'match_score', 'applied_at')
    list_filter = ('status', 'match_quality', 'applied_at', 'organization', 'training_opportunity__organization')
    search_fields = ('student__user__first_name', 'student__user__last_name', 'training_opportunity__title', 'organization__name')
    readonly_fields = ('applied_at', 'responded_at', 'created_at', 'updated_at', 'match_details_display')
    actions = ['accept_applications', 'reject_applications']
    inlines = [ApplicationStatusHistoryInline]
    
    fieldsets = (
        ('Application Details', {
            'fields': ('student', 'training_opportunity', 'organization')
        }),
        ('Matching Information', {
            'fields': ('match_score', 'match_quality', 'match_details_display')
        }),
        ('Status & Dates', {
            'fields': ('status', 'applied_at', 'responded_at')
        }),
        ('Acceptance/Rejection', {
            'fields': ('acceptance_letter', 'rejection_reason', 'start_date', 'end_date'),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def student_name(self, obj):
        return obj.student.full_name
    student_name.short_description = 'Student'
    student_name.admin_order_field = 'student__user__first_name'
    
    def opportunity_title(self, obj):
        return obj.training_opportunity.title
    opportunity_title.short_description = 'Opportunity'
    
    def organization_name(self, obj):
        return obj.organization.name
    organization_name.short_description = 'Organization'
    
    def match_details_display(self, obj):
        if not obj.match_details:
            return 'No details available'
        details = obj.match_details
        html_items = []
        for key, value in details.items():
            html_items.append(f'<strong>{key.replace("_", " ").title()}:</strong> {value}<br>')
        return format_html(''.join(html_items))
    match_details_display.short_description = 'Match Details'
    
    def accept_applications(self, request, queryset):
        """Bulk accept applications"""
        for app in queryset.filter(status='pending'):
            app.accept()
        self.message_user(request, f'{queryset.filter(status="accepted").count()} applications accepted.')
    accept_applications.short_description = 'Accept selected applications'
    
    def reject_applications(self, request, queryset):
        """Bulk reject applications"""
        for app in queryset.filter(status='pending'):
            app.reject()
        self.message_user(request, f'{queryset.filter(status="rejected").count()} applications rejected.')
    reject_applications.short_description = 'Reject selected applications'


# ============================================================================
# NOTIFICATION ADMIN
# ============================================================================

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'notification_type', 'is_read', 'created_at')
    list_filter = ('notification_type', 'is_read', 'created_at')
    search_fields = ('title', 'message', 'user__username', 'user__email')
    readonly_fields = ('created_at', 'read_at')
    
    fieldsets = (
        ('Notification Information', {
            'fields': ('user', 'notification_type', 'title', 'message')
        }),
        ('Related Objects', {
            'fields': ('application', 'training_opportunity'),
            'classes': ('collapse',)
        }),
        ('Status', {
            'fields': ('is_read', 'read_at')
        }),
        ('Timestamps', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )
    
    def has_add_permission(self, request):
        return False


# ============================================================================
# REVIEW ADMIN
# ============================================================================

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('student_name', 'organization_name', 'rating_display', 'is_verified', 'created_at')
    list_filter = ('rating', 'is_verified', 'created_at', 'organization')
    search_fields = ('student__user__first_name', 'student__user__last_name', 'organization__name', 'comment')
    readonly_fields = ('created_at', 'updated_at')
    
    fieldsets = (
        ('Review Information', {
            'fields': ('student', 'organization', 'application')
        }),
        ('Review Content', {
            'fields': ('rating', 'title', 'comment')
        }),
        ('Verification', {
            'fields': ('is_verified',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def student_name(self, obj):
        return obj.student.full_name
    student_name.short_description = 'Student'
    
    def organization_name(self, obj):
        return obj.organization.name
    organization_name.short_description = 'Organization'
    
    def rating_display(self, obj):
        stars = '⭐' * obj.rating
        return format_html(
            '<span style="background-color: #fff9c4; padding: 3px 8px; border-radius: 3px;">{} ({})</span>',
            stars,
            obj.rating
        )
    rating_display.short_description = 'Rating'


# ============================================================================
# SYSTEM CONFIG ADMIN
# ============================================================================

@admin.register(SystemConfig)
class SystemConfigAdmin(admin.ModelAdmin):
    list_display = ('key', 'value_preview', 'is_active', 'updated_at')
    list_filter = ('is_active', 'key', 'updated_at')
    search_fields = ('key', 'value', 'description')
    readonly_fields = ('updated_at',)
    
    fieldsets = (
        ('Configuration', {
            'fields': ('key', 'value', 'description')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('updated_at',),
            'classes': ('collapse',)
        }),
    )
    
    def value_preview(self, obj):
        preview = str(obj.value)[:50]
        if len(str(obj.value)) > 50:
            preview += '...'
        return preview
    value_preview.short_description = 'Value'


# ============================================================================
# ADMIN SITE CUSTOMIZATION
# ============================================================================

admin.site.site_header = 'SITMS Administration Portal'
admin.site.site_title = 'SITMS Admin'
admin.site.index_title = 'Smart Industrial Training Matching System'
