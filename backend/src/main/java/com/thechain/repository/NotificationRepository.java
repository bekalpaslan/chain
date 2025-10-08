package com.thechain.repository;

import com.thechain.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findAllByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    List<Notification> findAllByUserIdAndReadAtIsNullOrderByCreatedAtDesc(UUID userId);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.userId = :userId AND n.readAt IS NULL")
    long countUnreadByUserId(@Param("userId") UUID userId);

    @Modifying
    @Query("UPDATE Notification n SET n.readAt = :readAt WHERE n.id = :notificationId")
    void markAsRead(@Param("notificationId") UUID notificationId, @Param("readAt") Instant readAt);

    @Modifying
    @Query("UPDATE Notification n SET n.readAt = :readAt WHERE n.userId = :userId AND n.readAt IS NULL")
    void markAllAsReadForUser(@Param("userId") UUID userId, @Param("readAt") Instant readAt);

    @Query("SELECT n FROM Notification n WHERE n.sentAt IS NULL AND n.priority = 'CRITICAL' ORDER BY n.createdAt ASC")
    List<Notification> findUnsentCriticalNotifications();

    List<Notification> findAllByNotificationTypeAndCreatedAtAfter(
        Notification.NotificationType type,
        Instant after
    );
}
