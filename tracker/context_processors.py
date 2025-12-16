"""
Context processors for Django templates.
Adds global context variables available to all templates.
"""


def header_notifications(request):
    """
    Context processor to add header notifications and alerts to template context.
    """
    context = {
        'notifications': [],
        'unread_count': 0,
    }
    
    # Add user notifications if user is authenticated
    if request.user and request.user.is_authenticated:
        try:
            from tracker.models import Notification
            
            # Get unread notifications for the user
            notifications = Notification.objects.filter(
                user=request.user,
                is_read=False
            ).order_by('-created_at')[:5]
            
            context['notifications'] = notifications
            context['unread_count'] = notifications.count()
        except Exception:
            # Model doesn't exist yet, return empty context
            pass
    
    return context
