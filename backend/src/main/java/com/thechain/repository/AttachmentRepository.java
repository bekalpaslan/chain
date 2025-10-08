package com.thechain.repository;

import com.thechain.entity.Attachment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface AttachmentRepository extends JpaRepository<Attachment, UUID> {

    List<Attachment> findTop20ByOrderByAttachedAtDesc();

    @Query("SELECT a FROM Attachment a WHERE a.attachedAt >= :since ORDER BY a.attachedAt DESC")
    List<Attachment> findRecentAttachments(Instant since);
}
