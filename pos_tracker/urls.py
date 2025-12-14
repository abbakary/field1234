from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from tracker import views

# Create a router for viewsets
router = DefaultRouter()
router.register(r'institutions', views.InstitutionViewSet, basename='institution')
router.register(r'departments', views.DepartmentViewSet, basename='department')
router.register(r'courses', views.CourseViewSet, basename='course')
router.register(r'skills', views.SkillViewSet, basename='skill')
router.register(r'students', views.StudentViewSet, basename='student')
router.register(r'organizations', views.OrganizationViewSet, basename='organization')
router.register(r'training-opportunities', views.TrainingOpportunityViewSet, basename='training-opportunity')
router.register(r'applications', views.ApplicationViewSet, basename='application')
router.register(r'notifications', views.NotificationViewSet, basename='notification')
router.register(r'reviews', views.ReviewViewSet, basename='review')

urlpatterns = [
    # Admin interface
    path('admin/', admin.site.urls),
    
    # API Authentication endpoints
    path('api/auth/student-register/', views.student_register, name='student_register'),
    path('api/auth/organization-register/', views.organization_register, name='organization_register'),
    path('api/auth/login/', views.login, name='login'),
    path('api/auth/profile/', views.user_profile, name='user_profile'),
    
    # API v1 - ViewSets (handled by router)
    path('api/v1/', include(router.urls)),
    
    # Django REST Framework authentication endpoints
    path('api-auth/', include('rest_framework.urls')),
    
    # Legacy templates (if needed for admin interface)
    path('', include('tracker.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
