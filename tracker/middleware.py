from django.utils import timezone
from django.contrib.auth.models import AnonymousUser
from datetime import timedelta


class TimezoneMiddleware:
    """
    Middleware to set timezone based on user preferences or default timezone.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Set timezone based on user preference if authenticated
        if request.user and not isinstance(request.user, AnonymousUser):
            # You can add user timezone preference later
            # For now, use Django's default timezone
            pass
        
        response = self.get_response(request)
        return response


class AutoProgressOrdersMiddleware:
    """
    Middleware to automatically progress orders based on time elapsed.
    This runs on every request to check if any orders need status updates.
    """
    def __init__(self, get_response):
        self.get_response = get_response
        self.last_check = None
        self.check_interval = 60  # Check every 60 seconds

    def __call__(self, request):
        # Import here to avoid circular imports
        from tracker.models import Order
        from django.utils import timezone as django_timezone
        
        now = django_timezone.now()
        
        # Only check periodically, not on every request
        if self.last_check is None or (now - self.last_check).total_seconds() >= self.check_interval:
            try:
                self._auto_progress_orders()
                self.last_check = now
            except Exception as e:
                # Log error but don't fail the request
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Error auto-progressing orders: {str(e)}")
        
        response = self.get_response(request)
        return response

    def _auto_progress_orders(self):
        """
        Auto-progress orders based on elapsed time.
        For example: pending -> in_progress after 5 minutes, etc.
        """
        try:
            from tracker.models import Order
            from django.utils import timezone as django_timezone
            
            now = django_timezone.now()
            
            # Example: Auto-progress pending orders to in_progress after 5 minutes
            five_minutes_ago = now - timedelta(minutes=5)
            
            pending_orders = Order.objects.filter(
                status='pending',
                created_at__lte=five_minutes_ago
            )
            
            # Update orders to next status
            for order in pending_orders:
                if hasattr(order, 'auto_progress_status'):
                    order.auto_progress_status()
                    order.save()
        except Exception as e:
            # Silently fail if Order model doesn't exist or has issues
            pass
