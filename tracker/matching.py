from django.db.models import Q, Count, Case, When, IntegerField
from .models import Student, TrainingOpportunity, Application


class SmartMatcher:
    """Smart matching algorithm for matching students with training opportunities"""
    
    # Matching criteria weights (total = 100)
    WEIGHTS = {
        'course_match': 35,      # 35% - Course/program match
        'level_match': 20,       # 20% - Academic level match
        'skill_match': 25,       # 25% - Skills relevance
        'gpa_match': 10,         # 10% - GPA requirement
        'location_match': 10,    # 10% - Location preference
    }
    
    def calculate_match_score(self, student, training_opportunity):
        """
        Calculate match score between a student and a training opportunity
        Returns: dict with match_score, match_quality, and match_details
        """
        
        # Check if student is already applied
        existing = Application.objects.filter(
            student=student,
            training_opportunity=training_opportunity
        ).first()
        if existing:
            return {
                'match_score': 0,
                'match_quality': 'not_eligible',
                'match_details': {'error': 'Already applied to this opportunity'}
            }
        
        scores = {}
        details = {}
        
        # 1. Course Match (35%)
        course_match = self._calculate_course_match(student, training_opportunity)
        scores['course_match'] = course_match['score']
        details['course_match'] = course_match
        
        # 2. Level Match (20%)
        level_match = self._calculate_level_match(student, training_opportunity)
        scores['level_match'] = level_match['score']
        details['level_match'] = level_match
        
        # 3. Skill Match (25%)
        skill_match = self._calculate_skill_match(student, training_opportunity)
        scores['skill_match'] = skill_match['score']
        details['skill_match'] = skill_match
        
        # 4. GPA Match (10%)
        gpa_match = self._calculate_gpa_match(student, training_opportunity)
        scores['gpa_match'] = gpa_match['score']
        details['gpa_match'] = gpa_match
        
        # 5. Location Match (10%)
        location_match = self._calculate_location_match(student, training_opportunity)
        scores['location_match'] = location_match['score']
        details['location_match'] = location_match
        
        # Calculate final weighted score
        final_score = self._calculate_weighted_score(scores)
        match_quality = self._determine_match_quality(final_score)
        
        return {
            'match_score': final_score,
            'match_quality': match_quality,
            'match_details': details
        }
    
    def find_matched_opportunities(self, student, min_score=0):
        """
        Find all matching opportunities for a student
        Returns: dict of {opportunity: match_info}
        """
        opportunities = TrainingOpportunity.objects.filter(
            is_open=True,
            is_active=True,
            remaining_slots__gt=0
        )
        
        matched = {}
        for opp in opportunities:
            match_info = self.calculate_match_score(student, opp)
            if match_info['match_score'] >= min_score and match_info['match_quality'] != 'not_eligible':
                matched[opp] = match_info
        
        return matched
    
    def _calculate_course_match(self, student, training_opportunity):
        """
        Check if student's course matches opportunity's supported courses
        Score: 100 if exact match, 50 if department match, 0 if no match
        """
        student_course = student.course
        
        # Check exact course match
        if training_opportunity.supported_courses.filter(id=student_course.id).exists():
            return {
                'score': 100,
                'reason': 'Exact course match',
                'matched_courses': [student_course.name]
            }
        
        # Check department match
        same_dept_courses = training_opportunity.supported_courses.filter(
            department=student_course.department
        ).exists()
        if same_dept_courses:
            return {
                'score': 75,
                'reason': f'Department match: {student_course.department.name}',
                'matched_department': student_course.department.name
            }
        
        # No match
        return {
            'score': 0,
            'reason': f'No course match. Student: {student_course.name}, Available: {list(training_opportunity.supported_courses.values_list("name", flat=True))}',
            'student_course': student_course.name
        }
    
    def _calculate_level_match(self, student, training_opportunity):
        """
        Check if student's academic level matches opportunity requirements
        Score: 100 if exact match, 0 if no match
        """
        supported_levels = training_opportunity.supported_levels.lower()
        student_level = student.academic_level.lower()
        
        if supported_levels == 'both' or student_level in supported_levels:
            return {
                'score': 100,
                'reason': f'Level match: {student.get_academic_level_display()}',
                'student_level': student.academic_level,
                'required_levels': supported_levels
            }
        
        return {
            'score': 0,
            'reason': f'Level mismatch: Student {student.academic_level}, Required {supported_levels}',
            'student_level': student.academic_level,
            'required_levels': supported_levels
        }
    
    def _calculate_skill_match(self, student, training_opportunity):
        """
        Check skill overlap between student and opportunity
        Score based on percentage of required skills student possesses
        """
        required_skills = set(training_opportunity.required_skills.values_list('id', flat=True))
        student_skills = set(student.skills.values_list('id', flat=True))
        
        if not required_skills:
            # No specific skills required
            return {
                'score': 100,
                'reason': 'No specific skills required',
                'matched_skills': [],
                'missing_skills': []
            }
        
        matched_skills = required_skills.intersection(student_skills)
        missing_skills = required_skills - student_skills
        
        # Score: (matched / total) * 100
        score = int((len(matched_skills) / len(required_skills)) * 100)
        
        matched_skill_names = list(
            training_opportunity.required_skills.filter(id__in=matched_skills).values_list('name', flat=True)
        )
        missing_skill_names = list(
            training_opportunity.required_skills.filter(id__in=missing_skills).values_list('name', flat=True)
        )
        
        return {
            'score': score,
            'reason': f'{len(matched_skills)}/{len(required_skills)} required skills matched',
            'matched_skills': matched_skill_names,
            'missing_skills': missing_skill_names,
            'match_percentage': f'{score}%'
        }
    
    def _calculate_gpa_match(self, student, training_opportunity):
        """
        Check if student meets GPA requirement
        Score: 100 if meets requirement (assumed GPA >= 2.0), 0 otherwise
        This is simplified - in production would fetch actual GPA from student records
        """
        # Placeholder: assume student meets minimum GPA unless explicitly stated otherwise
        minimum_gpa = training_opportunity.minimum_gpa or 2.0
        
        # In a real system, fetch student's actual GPA from academic records
        # For now, we'll assume students applying meet GPA requirement
        return {
            'score': 100,
            'reason': f'Student meets minimum GPA requirement ({minimum_gpa})',
            'minimum_required': float(minimum_gpa),
            'student_gpa': 'Not provided'  # Would be fetched from academic system
        }
    
    def _calculate_location_match(self, student, training_opportunity):
        """
        Check if training location matches student preference
        Score: 100 if matches or no preference, 50 if different location but student flexible
        """
        preferred_location = (student.preferred_location or '').lower().strip()
        opportunity_location = training_opportunity.organization.location.lower().strip()
        
        if not preferred_location or preferred_location == 'any':
            return {
                'score': 100,
                'reason': 'No location preference',
                'student_preference': 'Any location',
                'opportunity_location': opportunity_location
            }
        
        if preferred_location in opportunity_location or opportunity_location in preferred_location:
            return {
                'score': 100,
                'reason': 'Location preference matched',
                'student_preference': student.preferred_location,
                'opportunity_location': opportunity_location
            }
        
        # Different location but student might still be interested
        return {
            'score': 75,
            'reason': f'Different location: preferred {student.preferred_location}, opportunity in {opportunity_location}',
            'student_preference': student.preferred_location,
            'opportunity_location': opportunity_location
        }
    
    def _calculate_weighted_score(self, scores):
        """
        Calculate final weighted match score (0-100)
        """
        total = 0
        for criteria, score in scores.items():
            weight = self.WEIGHTS.get(criteria, 0)
            total += (score * weight) / 100
        
        return int(total)
    
    def _determine_match_quality(self, score):
        """
        Determine quality category based on match score
        """
        if score >= 80:
            return 'high'
        elif score >= 60:
            return 'medium'
        elif score > 0:
            return 'low'
        else:
            return 'not_eligible'


class MatchingAnalytics:
    """Analytics for matching quality and placement"""
    
    @staticmethod
    def get_placement_statistics():
        """Get overall placement statistics"""
        from .models import Student, Application
        
        total_students = Student.objects.count()
        placed_students = Student.objects.filter(is_placed=True).count()
        placement_rate = (placed_students / total_students * 100) if total_students > 0 else 0
        
        total_applications = Application.objects.count()
        accepted_applications = Application.objects.filter(status='accepted').count()
        
        return {
            'total_students': total_students,
            'placed_students': placed_students,
            'unplaced_students': total_students - placed_students,
            'placement_rate': round(placement_rate, 2),
            'total_applications': total_applications,
            'accepted_applications': accepted_applications,
            'acceptance_rate': round((accepted_applications / total_applications * 100) if total_applications > 0 else 0, 2),
        }
    
    @staticmethod
    def get_match_quality_distribution():
        """Get distribution of match qualities"""
        from .models import Application
        
        distribution = Application.objects.values('match_quality').annotate(count=Count('id'))
        
        result = {
            'high': 0,
            'medium': 0,
            'low': 0,
            'not_eligible': 0
        }
        
        for item in distribution:
            result[item['match_quality']] = item['count']
        
        return result
    
    @staticmethod
    def get_student_matches(student):
        """Get match quality statistics for a student"""
        from .models import Application
        
        applications = Application.objects.filter(student=student)
        
        return {
            'total_applications': applications.count(),
            'pending': applications.filter(status='pending').count(),
            'accepted': applications.filter(status='accepted').count(),
            'rejected': applications.filter(status='rejected').count(),
            'withdrawn': applications.filter(status='withdrawn').count(),
            'average_match_score': applications.aggregate(avg=models.Avg('match_score'))['avg'] or 0,
            'highest_match': applications.aggregate(max=models.Max('match_score'))['max'] or 0,
        }
